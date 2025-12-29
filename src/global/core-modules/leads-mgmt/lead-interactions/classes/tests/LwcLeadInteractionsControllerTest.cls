/**
 * @description  : Test class for LwcLeadInteractionsController
 * @author       : Daniel Belini
 **/ @isTest
public with sharing class LwcLeadInteractionsControllerTest {
	@isTest
	static void testGetLeadInteractions() {
		Id leadId = createTestLead();
		String fieldSetName = createTestFieldSet();
		createTestLeadInteractionEntries(leadId); // Create test data

		Test.startTest();
		List<LwcLeadInteractionsController.LeadInteractionEntry> results = LwcLeadInteractionsController.getLeadInteractions(leadId, fieldSetName);
		Test.stopTest();

		System.assertNotEquals(null, results, 'Results should not be null');
		System.assert(results.size() > 0, 'Results should contain entries');
	}

	@isTest
	static void testGetLeadCurrentValues() {
		Id leadId = createTestLead();
		List<String> fields = new List<String>{ 'Name', 'Email' };

		Test.startTest();
		Map<String, Object> leadValues = LwcLeadInteractionsController.getLeadCurrentValues(leadId, fields);
		Test.stopTest();

		System.assertNotEquals(null, leadValues, 'Lead values should not be null');
		System.assert(leadValues.containsKey('Name'), 'Lead values should contain Name field');
	}

	private static Id createTestLead() {
		Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company');
		insert testLead;
		return testLead.Id;
	}

	private static String createTestFieldSet() {
		return 'LwcLeadLayoutFields';
	}

	private static void createTestLeadInteractionEntries(Id leadId) {
		List<SObject> leadInteractions = new List<SObject>();
		for (Integer i = 0; i < 3; i++) {
			LeadInteractionEntry__c interaction = new LeadInteractionEntry__c();
			interaction.Lead__c = leadId;
			interaction.Source__c = 'Test Source ' + i;
			leadInteractions.add(interaction);
		}
		insert leadInteractions;
	}
}
