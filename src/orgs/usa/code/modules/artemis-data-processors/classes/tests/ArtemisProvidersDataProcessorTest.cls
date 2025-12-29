/**
 * @description  : Unit tests for ArtemisProvidersDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisProvidersDataProcessorTest {
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
	static void shouldProcessPayloadForNewProvider() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisProviderRestModel payloadModel = new ArtemisProviderRestModel();
		payloadModel.id = '12345';
		payloadModel.firstName = 'John';
		payloadModel.lastName = 'Doe';
		payloadModel.middleName = 'A';
		payloadModel.npi = '1234567890';
		payloadModel.address = new ArtemisAddressRestModel();
		payloadModel.address.street = '123 Main St';

		ArtemisProvidersDataProcessor processor = new ArtemisProvidersDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'There should be one record in the database');
		Contact updatedRecord = [
			SELECT Id, FirstName, LastName, MiddleName, MailingStreet
			FROM Contact
			WHERE FirstName = 'John' AND LastName = 'Doe'
		];
		Assert.isNotNull(updatedRecord, 'New record should be created');
		Assert.areEqual('John', updatedRecord.FirstName, 'First name should be John');
		Assert.areEqual('Doe', updatedRecord.LastName, 'Last name should be Doe');
		Assert.areEqual('A', updatedRecord.MiddleName, 'Middle name should be A');
		Assert.areEqual('123 Main St', updatedRecord.MailingStreet, 'Mailing street should be 123 Main St');
	}

	@isTest
	static void shouldProcessPayloadForExistingProvider() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		// Create an existing record
		Contact existingRecord = new Contact(
			RecordTypeId = RecordTypes.CONTACT_PROVIDER.Id,
			FirstName = 'John',
			LastName = 'Doe',
			ProviderNpi__c = '1234567890'
		);
		insert existingRecord;
		// Create contact reference
		insert new EmrServerContactReference__c(Contact__c = existingRecord.Id, EmrServer__c = emrServer.emrServerId, Identifier__c = '12345');

		// Create a new payload with the same ID but different values
		ArtemisProviderRestModel payloadModel = new ArtemisProviderRestModel();
		payloadModel.id = '12345';
		payloadModel.firstName = 'John';
		payloadModel.lastName = 'Doe';
		payloadModel.middleName = 'Antony'; // new change
		payloadModel.npi = '1234567890';

		ArtemisProvidersDataProcessor processor = new ArtemisProvidersDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'There should be one record in the database');
		Contact updatedRecord = [
			SELECT Id, FirstName, LastName, MiddleName
			FROM Contact
			WHERE Id = :existingRecord.Id
		];

		Assert.areEqual('Antony', updatedRecord.MiddleName, 'Middle name should be updated to Antony');
		Assert.areEqual('John', updatedRecord.FirstName, 'First name should remain the same');
		Assert.areEqual('Doe', updatedRecord.LastName, 'Last name should remain the same');
	}

	@isTest
	static void shouldProcessPayloadForExistingProviderWithSameNpi() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		// Create an existing record
		Contact existingRecord = new Contact(
			RecordTypeId = RecordTypes.CONTACT_PROVIDER.Id,
			FirstName = 'John',
			LastName = 'Doe',
			ProviderNpi__c = '1234567890'
		);
		insert existingRecord;
		// No need to create contact reference for this test

		// Create a new payload with the same ID but different values
		ArtemisProviderRestModel payloadModel = new ArtemisProviderRestModel();
		payloadModel.id = '12345';
		payloadModel.firstName = 'John';
		payloadModel.lastName = 'Doe';
		payloadModel.middleName = 'Antony'; // new change
		payloadModel.npi = '1234567890';

		ArtemisProvidersDataProcessor processor = new ArtemisProvidersDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');

		Assert.areEqual(1, [SELECT COUNT() FROM Contact], 'There should be one record in the database');
		Contact updatedRecord = [
			SELECT Id, FirstName, LastName, MiddleName, ProviderNpi__c
			FROM Contact
			WHERE Id = :existingRecord.Id
			LIMIT 1
		];

		Assert.areEqual('Antony', updatedRecord.MiddleName, 'Middle name should remain the same');
		Assert.areEqual('John', updatedRecord.FirstName, 'First name should remain the same');
		Assert.areEqual('Doe', updatedRecord.LastName, 'Last name should remain the same');
		Assert.areEqual('1234567890', updatedRecord.ProviderNpi__c, 'NPI should remain the same');

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerContactReference__c], 'There should be one record in the database');
		EmrServerContactReference__c reference = [
			SELECT Id, Contact__c, EmrServer__c, Identifier__c
			FROM EmrServerContactReference__c
			WHERE Contact__c = :existingRecord.Id AND EmrServer__c = :emrServer.emrServerId
			LIMIT 1
		];

		Assert.isNotNull(reference, 'Reference should be created');
		Assert.areEqual('12345', reference.Identifier__c, 'Identifier should be 12345');
	}
}
