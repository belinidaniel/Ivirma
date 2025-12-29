/**
 * @description  : This class is responsible for processing Practitioner data from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisPractitionersDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisPractitionersDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<String> practitionerIds = Collection.of(payloads).collect(new PractitionerIdMapper()).getSetString();
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();
		Set<String> practitionerNpis = Collection.of(payloads).collect(new PractitionerNpiMapper()).getSetString();
		practitionerNpis.remove(null); // Remove any null NPI value, if any.

		Map<String, EmrServerContactReference__c> emrPractitionerReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery()
					.byEmrServerId(emrServerIds)
					.byField(EmrServerContactReference__c.ArtemisPractitionerIdentifier__c, 'IN', practitionerIds)
					.getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.ArtemisPractitionerIdentifier__c);

		Map<Id, Contact> existingPractitionersById = (Map<Id, Contact>) new ProviderQuery()
			.withErmServerReference(emrPractitionerReferencesByServerAndKey.values())
			.getMapById();

		Map<String, Contact> existingContactsByNpi = (Map<String, Contact>) new ProviderQuery().byNpi(practitionerNpis).getMapByString(Contact.ProviderNpi__c);

		Map<String, EmrServerContactReference__c> emrContactReferencesByServerAndContactId = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byContactId(existingContactsByNpi.values()).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Contact__c);

		PractitionerPreparedData result = new PractitionerPreparedData();
		result.emrPractitionerReferencesByServerAndKey = emrPractitionerReferencesByServerAndKey;
		result.existingPractitionersById = existingPractitionersById;
		result.existingContactsByNpi = existingContactsByNpi;
		result.emrContactReferencesByServerAndContactId = emrContactReferencesByServerAndContactId;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		/**
		 * TODO
		 * If there is no reference, find by NPI. If there is no NPI found, create a new contact with this reference.
		 * If there is no reference, but there is an NPI, update the reference with the Practitioner External Id - dont do anything else.
		 * If there is a reference, skip..
		 */
		//throw new EmrServerDataProcessException('Practitioner processing not implemented yet.');

		PractitionerPreparedData preparedData = (PractitionerPreparedData) context.preparedData;
		ArtemisPractitionerRestModel practitionerPayload = (ArtemisPractitionerRestModel) payload;

		String sourceEmrServerId = context.sourceServer.emrServerId;
		String practitionerId = practitionerPayload.id;

		EmrServerContactReference__c emrPractitionerReference = preparedData.emrPractitionerReferencesByServerAndKey.get(
			sourceEmrServerId + '' + practitionerId
		);

		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();

		Boolean referenceUpdated = false;
		Contact existingPractitionerRecord = null;
		if (emrPractitionerReference == null) {
			//Contact does not exist, so we need to find it by NPI, if it has one.
			if (String.isNotBlank(practitionerPayload.npi)) {
				Contact existingPractitionerByNpi = preparedData.existingContactsByNpi.get(practitionerPayload.npi);
				if (existingPractitionerByNpi != null) {
					//Found a contact by NPI, so we need to create or update its reference
					existingPractitionerRecord = existingPractitionerByNpi;

					//Get the existing reference, if any
					EmrServerContactReference__c reference = preparedData.emrContactReferencesByServerAndContactId.get(
						sourceEmrServerId + '' + existingPractitionerByNpi.Id
					);

					if (reference != null) {
						//Reference already exists, so we need to update it to the new practitioner id
						emrPractitionerReference = reference;
						reference.ArtemisPractitionerIdentifier__c = practitionerPayload.id;
						reference.LastSyncDateTime__c = System.now();
						databaseService.updateRecord(reference);
					} else {
						//Reference does not exist, so we need to create it
						emrPractitionerReference = new EmrServerContactReference__c(
							Contact__c = existingPractitionerByNpi.Id,
							EmrServer__c = context.sourceServer.emrServerId,
							ArtemisPractitionerIdentifier__c = practitionerPayload.id,
							LastSyncDateTime__c = System.now()
						);
						databaseService.insertRecord(emrPractitionerReference);
					}
					referenceUpdated = true;
				}
			}
		} else {
			//Reference already exists, so we need will just need to update the contact record
			existingPractitionerRecord = preparedData.existingPractitionersById.get(emrPractitionerReference.Contact__c);
		}

		if (existingPractitionerRecord == null) {
			//No contact was found so far, let us create a new one
			Contact newPractitioner = practitionerPayload.toSObject();
			databaseService.insertRecord(newPractitioner);

			//Create a new reference for the newly created practitioner
			emrPractitionerReference = new EmrServerContactReference__c(
				Contact__c = newPractitioner.Id,
				EmrServer__c = context.sourceServer.emrServerId,
				ArtemisPractitionerIdentifier__c = practitionerPayload.id,
				LastSyncDateTime__c = System.now()
			);
			databaseService.insertRecord(emrPractitionerReference);
		} else {
			//Update the existing contact record
			Contact updatedPractitioner = practitionerPayload.toSObject(existingPractitionerRecord.Id);
			databaseService.updateRecord(updatedPractitioner);

			if (referenceUpdated == false) {
				emrPractitionerReference.LastSyncDateTime__c = System.now();
				databaseService.updateRecord(emrPractitionerReference);
			}
		}
	}

	private class PractitionerPreparedData {
		public Map<String, EmrServerContactReference__c> emrPractitionerReferencesByServerAndKey { get; set; }
		public Map<Id, Contact> existingPractitionersById { get; set; }
		public Map<String, Contact> existingContactsByNpi { get; set; }
		public Map<String, EmrServerContactReference__c> emrContactReferencesByServerAndContactId { get; set; }
	}

	private class PractitionerIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPractitionerRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class PractitionerNpiMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPractitionerRestModel) item).npi;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
