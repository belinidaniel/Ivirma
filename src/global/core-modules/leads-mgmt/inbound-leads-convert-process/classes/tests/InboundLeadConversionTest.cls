/**
 * @description  : Test class for InboundLeadConversion.
 * @author       : Daniel Belini
 * @testSuite    : InboundLeadsProcessing
 **/
@IsTest
private class InboundLeadConversionTest {
	@TestSetup
	static void setupTestData() {
		Campaign testCampaign = new Campaign(Name = 'FooCampaign');
		insert testCampaign;

		// Create test Lead
		Lead testLead = new Lead(LastName = 'FooBar', Email = 'foo.bar@example.com');
		insert testLead;
	}

	@isTest
	static void shouldCreateNewLeadWithLeadInteractionEntry() {
		InboundLead__c inboundLead = new InboundLead__c(
			Email__c = 'john.doe@example.com',
			FirstName__c = 'John',
			LastName__c = 'Doe',
			AddressStateCode__c = 'NY'
		);

		InboundLeadConversion inboundLeadConversion = new InboundLeadConversion(new List<InboundLead__c>{ inboundLead });
		inboundLeadConversion.customPluginType = null; // disable the custom plugin, if any in the current org, to force the default behavior

		Test.startTest();
		List<InboundLeadConversion.InboundLeadConversionResult> results = inboundLeadConversion.convert(false);
		Test.stopTest();

		Assert.areEqual(1, results.size(), 'One result should be returned');
		Assert.areEqual(true, results[0].success, 'The conversion should be successful');
		Assert.areNotEqual(null, results[0].resultLead, 'The lead should be created/updated');
		Assert.areNotEqual(null, results[0].resultLeadInteractionEntry, 'The lead interaction entry should be created');
		Assert.areEqual('John', results[0].resultLead.FirstName, 'The lead first name should be mapped correctly');
		Assert.areEqual('Doe', results[0].resultLead.LastName, 'The lead last name should be mapped correctly');
		Assert.areEqual('john.doe@example.com', results[0].resultLead.Email, 'The lead email should be mapped correctly');
		Assert.areEqual('NY', results[0].resultLead.StateCode, 'The lead address state code should be mapped correctly');
		Assert.areEqual('John', results[0].resultLeadInteractionEntry.FirstName__c, 'The lead interaction entry first name should be mapped correctly');
		Assert.areEqual('Doe', results[0].resultLeadInteractionEntry.LastName__c, 'The lead interaction entry last name should be mapped correctly');
		Assert.areEqual('john.doe@example.com', results[0].resultLeadInteractionEntry.Email__c, 'The lead interaction entry email should be mapped correctly');
		Assert.areEqual(
			'NY',
			results[0].resultLeadInteractionEntry.Address__StateCode__s,
			'The lead interaction entry address state code should be mapped correctly'
		);
	}

	@isTest
	static void shouldMatchExistingLeadAndCreateNewLeadInteractionEntry() {
		Id existingLeadId = Query.fromSObject(Lead.SObjectType).byField(Lead.Email, '=', 'foo.bar@example.com').getFirstIdOrNull();

		InboundLead__c inboundLead = new InboundLead__c(
			Email__c = 'foo.bar@example.com',
			LastName__c = 'Bar',
			FirstName__c = 'Foo',
			AddressStateCode__c = 'NY'
		);

		InboundLeadConversion inboundLeadConversion = new InboundLeadConversion(new List<InboundLead__c>{ inboundLead });
		inboundLeadConversion.customPluginType = null; // disable the custom plugin, if any in the current org, to force the default behavior

		Test.startTest();
		List<InboundLeadConversion.InboundLeadConversionResult> results = inboundLeadConversion.convert(false);
		Test.stopTest();

		Assert.areEqual(1, results.size(), 'One result should be returned');
		Assert.areEqual(true, results[0].success, 'The conversion should be successful');
		Assert.areEqual(existingLeadId, results[0].resultLead.Id, 'The lead should be the existing lead');
		Assert.areNotEqual(null, results[0].resultLeadInteractionEntry, 'The lead interaction entry should be created');

		//No need to check lead fields, since they arent mapped into the lead when the lead is matched.

		Assert.areEqual('Foo', results[0].resultLeadInteractionEntry.FirstName__c, 'The lead interaction entry first name should be mapped correctly');
		Assert.areEqual('Bar', results[0].resultLeadInteractionEntry.LastName__c, 'The lead interaction entry last name should be mapped correctly');
		Assert.areEqual('foo.bar@example.com', results[0].resultLeadInteractionEntry.Email__c, 'The lead interaction entry email should be mapped correctly');
		Assert.areEqual(
			'NY',
			results[0].resultLeadInteractionEntry.Address__StateCode__s,
			'The lead interaction entry address state code should be mapped correctly'
		);
	}

	@IsTest
	static void testProcessInboundLeadMatchingExistingLeadWithCampaignReference() {
		InboundLead__c inboundLead = new InboundLead__c(
			Email__c = 'foo.bar@example.com',
			CampaignReference__c = [SELECT Id FROM Campaign WHERE Name = 'FooCampaign']
			.Id
		);

		InboundLeadConversion inboundLeadConversion = new InboundLeadConversion(new List<InboundLead__c>{ inboundLead });
		inboundLeadConversion.customPluginType = null; // disable the custom plugin, if any in the current org, to force the default behavior

		Test.startTest();
		List<InboundLeadConversion.InboundLeadConversionResult> results = inboundLeadConversion.convert(false);
		Test.stopTest();

		Assert.areEqual(1, results.size(), 'One result should be returned');
		Assert.areEqual(true, results[0].success, 'The conversion should be successful');
		Assert.areNotEqual(null, results[0].resultLead, 'The lead should be created/updated');
		Assert.areNotEqual(null, results[0].resultLeadInteractionEntry, 'The lead interaction entry should be created');
	}

	@isTest
	static void shouldFailCreatingNewLead() {
		//Due to missing LastName
		InboundLead__c inboundLead = new InboundLead__c(Email__c = 'john.doe@example.com', FirstName__c = 'John');

		InboundLeadConversion inboundLeadConversion = new InboundLeadConversion(new List<InboundLead__c>{ inboundLead });
		inboundLeadConversion.customPluginType = null; // disable the custom plugin, if any in the current org, to force the default behavior

		Test.startTest();
		List<InboundLeadConversion.InboundLeadConversionResult> results = inboundLeadConversion.convert(false);
		Test.stopTest();

		Assert.areEqual(1, results.size(), 'One result should be returned');
		Assert.areEqual(false, results[0].success, 'The conversion should fail');
		Assert.isTrue(String.isNotBlank(results[0].errorMessage), 'The error message should be populated');
	}
}
