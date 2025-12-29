/**
 * @description Test class for EmrEntityReferencesStatusController
 * @author Ivo Rocha
 **/
@isTest
private class EmrEntityReferencesStatusControllerTest {
	// Setup test data
	@TestSetup
	static void makeData() {
		// Create EMR Servers
		List<EMRServer__c> servers = new List<EMRServer__c>();
		servers.add(new EMRServer__c(Name = 'Test Server 1', NamedCredential__c = 'Test1', APISchemaSpec__c = 'Artemis'));
		servers.add(new EMRServer__c(Name = 'Test Server 2', NamedCredential__c = 'Test2', APISchemaSpec__c = 'Artemis'));
		servers.add(new EMRServer__c(Name = 'Test Server 3', NamedCredential__c = 'Test3', APISchemaSpec__c = 'Artemis'));
		insert servers;

		// Create Account and Contact
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
		insert testContact;

		// Create references for some server-entity combinations
		EMRServer__c server1 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 1' LIMIT 1];
		EMRServer__c server2 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 2' LIMIT 1];

		// Create account reference for server 1
		EmrServerAccountReference__c accountRef = new EmrServerAccountReference__c(
			Account__c = testAccount.Id,
			EmrServer__c = server1.Id,
			Identifier__c = 'ACC-123',
			LastSyncDateTime__c = DateTime.now().addDays(-1)
		);
		insert accountRef;

		// Create contact reference for server 2
		EmrServerContactReference__c contactRef = new EmrServerContactReference__c(
			Contact__c = testContact.Id,
			EmrServer__c = server2.Id,
			Identifier__c = 'CON-456',
			LastSyncDateTime__c = DateTime.now().addDays(-1)
		);
		insert contactRef;
	}

	@isTest
	static void testGetEntityReferencesForAccountWithReferences() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

		Test.startTest();
		List<EmrEntityReferencesStatusController.EntityServerReference> results = EmrEntityReferencesStatusController.getEntityReferences(testAccount.Id);
		Test.stopTest();

		// Validate results
		Assert.areEqual(3, results.size(), 'Should return references for all 3 servers');

		// Check that references with existing values come first in the sorted list
		Assert.areNotEqual(null, results[0].reference, 'First item should have a reference');

		// Verify specific values
		Boolean foundExistingRef = false;
		for (EmrEntityReferencesStatusController.EntityServerReference ref : results) {
			if (ref.reference == 'ACC-123') {
				foundExistingRef = true;
				Assert.areEqual('Account', ref.entityName);
				Assert.areEqual(testAccount.Id, ref.entityId);
				Assert.areEqual('Test Server 1', ref.serverName);
				Assert.areNotEqual(null, ref.lastSync);
			}
		}
		Assert.isTrue(foundExistingRef, 'Should find the existing account reference');
	}

	@isTest
	static void testGetEntityReferencesForContactWithReferences() {
		Contact testContact = [SELECT Id FROM Contact LIMIT 1];

		Test.startTest();
		List<EmrEntityReferencesStatusController.EntityServerReference> results = EmrEntityReferencesStatusController.getEntityReferences(testContact.Id);
		Test.stopTest();

		// Validate results
		Assert.areEqual(3, results.size(), 'Should return references for all 3 servers');

		// Verify specific values
		Boolean foundExistingRef = false;
		for (EmrEntityReferencesStatusController.EntityServerReference ref : results) {
			if (ref.reference == 'CON-456') {
				foundExistingRef = true;
				Assert.areEqual('Contact', ref.entityName);
				Assert.areEqual(testContact.Id, ref.entityId);
				Assert.areEqual('Test Server 2', ref.serverName);
				Assert.areNotEqual(null, ref.lastSync);
			}
		}
		Assert.isTrue(foundExistingRef, 'Should find the existing contact reference');
	}

	@isTest
	static void testGetEntityReferencesWithNullEntityId() {
		try {
			EmrEntityReferencesStatusController.getEntityReferences(null);
			Assert.fail('Should have thrown an exception');
		} catch (AuraHandledException e) {
			//Assert.isTrue(e.getMessage().contains('Entity Id parameter cannot be null.'));
		}
	}

	@isTest
	static void testGetEntityReferencesWithInvalidObjectType() {
		// Create a reference to a different type of object, like User
		User u = [SELECT Id FROM User LIMIT 1];

		try {
			EmrEntityReferencesStatusController.getEntityReferences(u.Id);
			Assert.fail('Should have thrown an exception');
		} catch (AuraHandledException e) {
			//Assert.isTrue(e.getMessage().contains('Entity Id can only be of Account or Contact types'), 'Should throw exception for invalid object type');
		}
	}

	@isTest
	static void testCreateEntityReferenceForAccount() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		EMRServer__c server3 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 3' LIMIT 1];

		Test.startTest();
		EmrEntityReferencesStatusController.createEntityReference(testAccount.Id, server3.Id, 'NEW-ACC-789');
		Test.stopTest();

		// Verify the reference was created
		List<EmrServerAccountReference__c> refs = [
			SELECT Identifier__c
			FROM EmrServerAccountReference__c
			WHERE Account__c = :testAccount.Id AND EmrServer__c = :server3.Id
		];

		Assert.areEqual(1, refs.size(), 'Should have created one reference');
		Assert.areEqual('NEW-ACC-789', refs[0].Identifier__c, 'External ID should match');
	}

	@isTest
	static void testCreateEntityReferenceForContact() {
		Contact testContact = [SELECT Id FROM Contact LIMIT 1];
		EMRServer__c server3 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 3' LIMIT 1];

		Test.startTest();
		EmrEntityReferencesStatusController.createEntityReference(testContact.Id, server3.Id, 'NEW-CON-789');
		Test.stopTest();

		// Verify the reference was created
		List<EmrServerContactReference__c> refs = [
			SELECT Identifier__c
			FROM EmrServerContactReference__c
			WHERE Contact__c = :testContact.Id AND EmrServer__c = :server3.Id
		];

		Assert.areEqual(1, refs.size(), 'Should have created one reference');
		Assert.areEqual('NEW-CON-789', refs[0].Identifier__c, 'External ID should match');
	}

	@isTest
	static void testCreateEntityReferenceWithNullEntityId() {
		EMRServer__c server1 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 1' LIMIT 1];

		try {
			EmrEntityReferencesStatusController.createEntityReference(null, server1.Id, 'TEST');
			Assert.fail('Should have thrown an exception');
		} catch (AuraHandledException e) {
			//Assert.isTrue(e.getMessage().contains('Entity Id parameter cannot be null'), 'Should throw exception for null entity ID');
		}
	}

	@isTest
	static void testCreateEntityReferenceWithInvalidObjectType() {
		// Create a reference to a different type of object, like User
		User u = [SELECT Id FROM User LIMIT 1];
		EMRServer__c server1 = [SELECT Id FROM EMRServer__c WHERE Name = 'Test Server 1' LIMIT 1];

		try {
			EmrEntityReferencesStatusController.createEntityReference(u.Id, server1.Id, 'TEST');
			Assert.fail('Should have thrown an exception');
		} catch (AuraHandledException e) {
			//Assert.isTrue(e.getMessage().contains('Entity Id can only be of Account or Contact types'), 'Should throw exception for invalid object type');
		}
	}
}
