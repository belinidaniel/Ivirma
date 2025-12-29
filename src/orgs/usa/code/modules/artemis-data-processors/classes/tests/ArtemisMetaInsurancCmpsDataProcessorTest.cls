/**
 * @description  : Unit tests for ArtemisMetaInsuranceCompaniesDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisMetaInsurancCmpsDataProcessorTest {
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
	static void shouldProcessPayloadForNewInsuranceCompany() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisMetadataInsuranceCompanyRestModel payloadModel = new ArtemisMetadataInsuranceCompanyRestModel();
		payloadModel.id = '12345';
		payloadModel.name = 'New Insurance Company';

		ArtemisMetaInsuranceCompsDataProcessor processor = new ArtemisMetaInsuranceCompsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerInsuranceCompanyMetadata__c], 'There should be one record in the database');
	}

	@isTest
	static void shouldProcessPayloadForExistingInsuranceCompany() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		// Create an existing record
		EmrServerInsuranceCompanyMetadata__c existingRecord = new EmrServerInsuranceCompanyMetadata__c(
			InsuranceCompanyInternalId__c = '12345',
			Name = 'Insurance Company',
			EmrServer__c = emrServer.emrServerId
		);
		insert existingRecord;

		// Create a new payload with the same ID but different values
		ArtemisMetadataInsuranceCompanyRestModel payloadModel = new ArtemisMetadataInsuranceCompanyRestModel();
		payloadModel.id = '12345';
		payloadModel.name = 'Updated Insurance Company';

		ArtemisMetaInsuranceCompsDataProcessor processor = new ArtemisMetaInsuranceCompsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerInsuranceCompanyMetadata__c], 'There should be one record in the database');
		EmrServerInsuranceCompanyMetadata__c updatedRecord = [
			SELECT Id, Name
			FROM EmrServerInsuranceCompanyMetadata__c
			WHERE Id = :existingRecord.Id
		];
		Assert.areEqual('Updated Insurance Company', updatedRecord.Name, 'The record should be updated with the new name');
	}
}
