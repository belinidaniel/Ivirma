/**
 * @description  : Unit tests for ArtemisLocationsDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisLocationsDataProcessorTest {
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

		Account location = new Account(
			RecordTypeId = RecordTypes.ACCOUNT_LOCATION.id,
			Name = 'Location Foo Bar',
			LocationEmrServer__c = emrServer.Id,
			LocationArtemisExternalId__c = '12345'
		);
		insert location;
	}

	@isTest
	static void shouldCreateNewLocation() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisLocationRestModel payloadModel = new ArtemisLocationRestModel();
		payloadModel.id = '2002';
		payloadModel.name = 'Location Bar Foo';
		payloadModel.description = 'Location Bar Foo Description';
		payloadModel.address = new ArtemisAddressRestModel();
		payloadModel.address.countryCode = 'US';
		payloadModel.address.stateCode = 'CA';
		payloadModel.address.city = 'San Francisco';
		payloadModel.address.street = '123 Main St';
		payloadModel.address.zip = '12345';

		ArtemisLocationsDataProcessor processor = new ArtemisLocationsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'The result should be successful');

		Assert.areEqual(
			1,
			[SELECT COUNT() FROM Account WHERE LocationEmrServer__c = :emrServer.emrServerId AND LocationArtemisExternalId__c = :payloadModel.id],
			'The location should be created'
		);
		Account location = (Account) new LocationQuery().byEmrServerId(emrServer.emrServerId).byExternalId(payloadModel.id).getFirstOrNull();

		Assert.areEqual(payloadModel.id, location.LocationArtemisExternalId__c, 'The location should have the correct id');
		Assert.areEqual(payloadModel.name, location.Name, 'The location should have the correct name');
		Assert.areEqual(payloadModel.description, location.Description, 'The location should have the correct description');
		Assert.areEqual(payloadModel.address.countryCode, location.LocationAddress__CountryCode__s, 'The location should have the correct country code');
		Assert.areEqual(payloadModel.address.stateCode, location.LocationAddress__StateCode__s, 'The location should have the correct state code');
		Assert.areEqual(payloadModel.address.city, location.LocationAddress__City__s, 'The location should have the correct city');
		Assert.areEqual(payloadModel.address.street, location.LocationAddress__Street__s, 'The location should have the correct street');
		Assert.areEqual(payloadModel.address.zip, location.LocationAddress__PostalCode__s, 'The location should have the correct zip code');
	}

	@isTest
	static void shouldUpdateExistingLocation() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisLocationRestModel payloadModel = new ArtemisLocationRestModel();
		payloadModel.id = '12345';
		payloadModel.name = 'Location Bar Foo';

		ArtemisLocationsDataProcessor processor = new ArtemisLocationsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'The result should be successful');

		Assert.areEqual(
			1,
			[SELECT COUNT() FROM Account WHERE RecordTypeId = :RecordTypes.ACCOUNT_LOCATION.id],
			'There should be there only one location in the database'
		);

		Account location = (Account) new LocationQuery().byEmrServerId(emrServer.emrServerId).byExternalId(payloadModel.id).getFirstOrNull();
		Assert.areEqual(payloadModel.id, location.LocationArtemisExternalId__c, 'The location should have the correct id');
		Assert.areEqual(payloadModel.name, location.Name, 'The location should have the correct name');
	}
}
