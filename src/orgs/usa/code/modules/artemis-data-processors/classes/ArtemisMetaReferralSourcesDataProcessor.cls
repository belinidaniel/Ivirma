/**
 * @description  : This class is responsible for processing Referral Source metadata from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisMetaReferralSourcesDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisMetaReferralSourcesDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<String> metaIds = Collection.of(payloads).collect(new MetaReferralSourceIdMapper()).getSetString();
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();

		Map<String, EmrServerReferralSourceMetadata__c> existingReferralSourceMetadataByReference = (Map<String, EmrServerReferralSourceMetadata__c>) new EmrServerReferralSourceMetadataQuery()
			.byEmrServerId(emrServerIds)
			.byExternalId(metaIds)
			.getMapByString(EmrServerReferralSourceMetadata__c.ReferralSourceInternalId__c);

		MetaReferralSourcesPreparedData result = new MetaReferralSourcesPreparedData();
		result.existingReferralSourceMetadataByReference = existingReferralSourceMetadataByReference;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		MetaReferralSourcesPreparedData preparedData = (MetaReferralSourcesPreparedData) context.preparedData;
		ArtemisMetadataReferralSourceRestModel metaReferralSourcePayload = (ArtemisMetadataReferralSourceRestModel) payload;

		EmrServerReferralSourceMetadata__c existingReferralSourceMetadataByReference = preparedData.existingReferralSourceMetadataByReference.get(
			metaReferralSourcePayload.id
		);

		if (existingReferralSourceMetadataByReference != null && metaReferralSourcePayload.equals(existingReferralSourceMetadataByReference)) {
			//Ref. Source metadata already exists and there is no changes
			return;
		}

		EmrServerReferralSourceMetadata__c referralSourceRecord = metaReferralSourcePayload.toSObject(existingReferralSourceMetadataByReference?.Id);
		referralSourceRecord.EmrServer__c = context.sourceServer.emrServerId;

		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();
		databaseService.upsertRecord(referralSourceRecord, EmrServerReferralSourceMetadata__c.Id);
	}

	private class MetaReferralSourcesPreparedData {
		public Map<String, EmrServerReferralSourceMetadata__c> existingReferralSourceMetadataByReference { get; set; }
	}

	private class MetaReferralSourceIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisMetadataReferralSourceRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
