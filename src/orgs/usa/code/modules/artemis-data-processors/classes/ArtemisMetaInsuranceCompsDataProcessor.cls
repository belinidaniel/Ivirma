/**
 * @description  : This class is responsible for processing Insurance Company metadata from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisMetaInsuranceCompsDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisMetaInsuranceCompsDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<String> metaIds = Collection.of(payloads).collect(new MetaInsuranceProviderIdMapper()).getSetString();
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();

		Map<String, EmrServerInsuranceCompanyMetadata__c> existingInsuranceCompaniesMetadataByRef = (Map<String, EmrServerInsuranceCompanyMetadata__c>) new EmrServerInsuranceCompanyMetadataQuery()
			.byEmrServerId(emrServerIds)
			.byExternalId(metaIds)
			.getMapByString(EmrServerInsuranceCompanyMetadata__c.InsuranceCompanyInternalId__c);

		MetaInsuranceCompsPreparedData result = new MetaInsuranceCompsPreparedData();
		result.existingInsuranceCompaniesMetadataByRef = existingInsuranceCompaniesMetadataByRef;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		MetaInsuranceCompsPreparedData preparedData = (MetaInsuranceCompsPreparedData) context.preparedData;
		ArtemisMetadataInsuranceCompanyRestModel metaInsurancePayload = (ArtemisMetadataInsuranceCompanyRestModel) payload;

		EmrServerInsuranceCompanyMetadata__c existingInsuranceCompanyMetadataRecord = preparedData.existingInsuranceCompaniesMetadataByRef.get(
			metaInsurancePayload.id
		);

		if (existingInsuranceCompanyMetadataRecord != null && metaInsurancePayload.equals(existingInsuranceCompanyMetadataRecord)) {
			//Insurance Company metadata already exists and there is no changes
			return;
		}

		EmrServerInsuranceCompanyMetadata__c insuranceCompanyRecord = metaInsurancePayload.toSObject(existingInsuranceCompanyMetadataRecord?.Id);
		insuranceCompanyRecord.EmrServer__c = context.sourceServer.emrServerId;

		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();
		databaseService.upsertRecord(insuranceCompanyRecord, EmrServerInsuranceCompanyMetadata__c.Id);
	}

	private class MetaInsuranceCompsPreparedData {
		public Map<String, EmrServerInsuranceCompanyMetadata__c> existingInsuranceCompaniesMetadataByRef { get; set; }
	}

	private class MetaInsuranceProviderIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisMetadataInsuranceCompanyRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
