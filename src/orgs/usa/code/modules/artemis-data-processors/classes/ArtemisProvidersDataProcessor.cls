/**
 * @description  : This class is responsible for processing Provider data from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisProvidersDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisProvidersDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<String> providerIds = Collection.of(payloads).collect(new ProviderIdMapper()).getSetString();
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();
		Set<String> providerNpis = Collection.of(payloads).collect(new ProviderNpiMapper()).getSetString();
		providerNpis.remove(null); // Remove any null NPI value, if any.

		Map<String, EmrServerContactReference__c> ermProviderReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byIdentifier(providerIds).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Identifier__c);

		Map<Id, Contact> existingProvidersById = (Map<Id, Contact>) new ProviderQuery()
			.withErmServerReference(ermProviderReferencesByServerAndKey.values())
			.getMapById();

		Map<String, Contact> existingContactsByNpi = (Map<String, Contact>) new ProviderQuery().byNpi(providerNpis).getMapByString(Contact.ProviderNpi__c);

		Map<String, EmrServerContactReference__c> emrContactReferencesByServerAndContactId = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byContactId(existingContactsByNpi.values()).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Contact__c);

		ProviderPreparedData result = new ProviderPreparedData();
		result.ermProviderReferencesByServerAndKey = ermProviderReferencesByServerAndKey;
		result.existingProvidersById = existingProvidersById;
		result.existingContactsByNpi = existingContactsByNpi;
		result.emrContactReferencesByServerAndContactId = emrContactReferencesByServerAndContactId;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		ProviderPreparedData preparedData = (ProviderPreparedData) context.preparedData;
		ArtemisProviderRestModel providerPayload = (ArtemisProviderRestModel) payload;

		String sourceEmrServerId = context.sourceServer.emrServerId;
		String providerId = providerPayload.id;

		EmrServerContactReference__c ermProviderReference = preparedData.ermProviderReferencesByServerAndKey.get(sourceEmrServerId + '' + providerId);

		/**
		 * If there is no reference, it doesnt necessarily mean that the provider does not exist. It might exist through the NPI.
		 * So, in that case, we will try to find the provider by NPI too - if nothing is found, we will create a new provider, otherwise if it exists, we first need to create a new server reference.
		 * If there is a reference, we update the provider and the reference.
		 */
		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();

		Boolean referenceUpdated = false;
		Contact existingProviderRecord = null;
		if (ermProviderReference == null) {
			//Contact does not exist, so we need to find it by NPI, if it has one.
			if (String.isNotBlank(providerPayload.npi)) {
				Contact existingProviderByNpi = preparedData.existingContactsByNpi.get(providerPayload.npi);
				if (existingProviderByNpi != null) {
					//Found a contact by NPI, so we need to create or update its reference
					existingProviderRecord = existingProviderByNpi;

					//Get the existing reference, if any
					EmrServerContactReference__c reference = preparedData.emrContactReferencesByServerAndContactId.get(
						sourceEmrServerId + '' + existingProviderRecord.Id
					);

					if (reference != null) {
						//Reference already exists, so we need to update it to the new provider id
						ermProviderReference = reference;
						ermProviderReference.Identifier__c = providerId;
						ermProviderReference.ProviderCalendarId__c = providerPayload.calendarId;
						ermProviderReference.LastSyncDateTime__c = System.now();
						databaseService.updateRecord(ermProviderReference);
					} else {
						//Reference does not exist, so we need to create it
						ermProviderReference = new EmrServerContactReference__c(
							Contact__c = existingProviderByNpi.Id,
							EmrServer__c = context.sourceServer.emrServerId,
							Identifier__c = providerId,
							ProviderCalendarId__c = providerPayload.calendarId,
							LastSyncDateTime__c = System.now()
						);
						databaseService.insertRecord(ermProviderReference);
					}

					referenceUpdated = true;
				}
			}
		} else {
			existingProviderRecord = preparedData.existingProvidersById.get(ermProviderReference.Contact__c);
		}

		if (existingProviderRecord == null) {
			//No contact was found so far, let us create a new one
			Contact newProvider = providerPayload.toSObject();
			databaseService.insertRecord(newProvider);

			// Create a new reference for the newly created provider
			EmrServerContactReference__c newReference = new EmrServerContactReference__c(
				Contact__c = newProvider.Id,
				EmrServer__c = context.sourceServer.emrServerId,
				Identifier__c = providerId,
				ProviderCalendarId__c = providerPayload.calendarId,
				LastSyncDateTime__c = System.now()
			);
			databaseService.insertRecord(newReference);
		} else {
			//Update the existing contact record
			Contact updatedProvider = providerPayload.toSObject(existingProviderRecord.Id);
			databaseService.updateRecord(updatedProvider);

			if (referenceUpdated == false) {
				ermProviderReference.LastSyncDateTime__c = System.now();
				ermProviderReference.ProviderCalendarId__c = providerPayload.calendarId; //in case it ever changes
				databaseService.updateRecord(ermProviderReference);
			}
		}
	}

	private class ProviderPreparedData {
		public Map<String, EmrServerContactReference__c> ermProviderReferencesByServerAndKey { get; set; }
		public Map<Id, Contact> existingProvidersById { get; set; }
		public Map<String, Contact> existingContactsByNpi { get; set; }
		Map<String, EmrServerContactReference__c> emrContactReferencesByServerAndContactId { get; set; }
	}

	private class ProviderIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisProviderRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class ProviderNpiMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisProviderRestModel) item).npi;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
