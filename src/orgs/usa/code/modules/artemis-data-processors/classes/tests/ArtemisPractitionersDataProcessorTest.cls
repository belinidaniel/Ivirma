/**
 * @description  : Unit tests for ArtemisPractitionersDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisPractitionersDataProcessorTest {
	@TestSetup
	static void makeData() {
		EmrServer__c emrServer = new EmrServer__c(
			Name = 'XPTO',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
		);
		insert emrServer;

		Contact practitioner = new Contact(RecordTypeId = RecordTypes.CONTACT_PROVIDER.Id, FirstName = 'Foo', LastName = 'Bar', ProviderNpi__c = '1234567890');
		insert practitioner;

		EmrServerContactReference__c emrServerContactReference = new EmrServerContactReference__c(
			EmrServer__c = emrServer.Id,
			Contact__c = practitioner.Id,
			Identifier__c = '1234567890'
		);
		insert emrServerContactReference;
	}

	@isTest
	static void shouldCreateNewPractitioner() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisPractitionerRestModel payloadModel = new ArtemisPractitionerRestModel();
		payloadModel.id = '1234567890';
		payloadModel.firstName = 'Foo';
		payloadModel.lastName = 'Bar';
		payloadModel.npi = '1234567890';

		ArtemisPractitionersDataProcessor processor = new ArtemisPractitionersDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		//TODO: final logic when the processor is fully implemented
	}
}
