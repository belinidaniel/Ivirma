/**
 * @description  : Unit tests for ArtemisMetaReferralSourcesDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisMetaRefSourcesDataProcessorTest {
	@TestSetup
	static void makeData() {
		insert new EmrServer__c(
			Name = 'XPTO',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
		);
	}

	@isTest
	static void shouldProcessPayloadForNewReferralSource() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisMetadataReferralSourceRestModel payloadModel = new ArtemisMetadataReferralSourceRestModel();
		payloadModel.id = '12345';
		payloadModel.refBy = 'John Doe';
		payloadModel.refCat = new ArtemisMetadataReferralSourceRestModel.ReferenceCategory();
		payloadModel.refCat.id = '67890';
		payloadModel.refCat.name = 'Doctor';

		ArtemisMetaReferralSourcesDataProcessor processor = new ArtemisMetaReferralSourcesDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerReferralSourceMetadata__c], 'There should be one record in the database');
	}

	@isTest
	static void shouldProcessPayloadForExistingReferralSource() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		// Create an existing record
		EmrServerReferralSourceMetadata__c existingRecord = new EmrServerReferralSourceMetadata__c(
			ReferralSourceInternalId__c = '12345',
			ReferredBy__c = 'NewYorkMag',
			ReferralCategory__c = 'Magazine',
			ReferralCategoryInternalId__c = '67890',
			EmrServer__c = emrServer.emrServerId
		);
		insert existingRecord;

		// Create a new payload with the same ID but different values
		ArtemisMetadataReferralSourceRestModel payloadModel = new ArtemisMetadataReferralSourceRestModel();
		payloadModel.id = '12345';
		payloadModel.refBy = 'NewYorkMagazine'; //Different value
		payloadModel.refCat = new ArtemisMetadataReferralSourceRestModel.ReferenceCategory();
		payloadModel.refCat.id = '67890';
		payloadModel.refCat.name = 'Magazine';

		ArtemisMetaReferralSourcesDataProcessor processor = new ArtemisMetaReferralSourcesDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');
		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerReferralSourceMetadata__c], 'There should be one record in the database');
		EmrServerReferralSourceMetadata__c updatedRecord = [
			SELECT Id, ReferredBy__c
			FROM EmrServerReferralSourceMetadata__c
			WHERE Id = :existingRecord.Id
		];
		Assert.areEqual('NewYorkMagazine', updatedRecord.ReferredBy__c, 'The record should be updated with the new name');
	}
}
