/**
 * @description       : Test class for InboundLeadConversionPluginImpl.
 * @author            : Daniel Belini
 * @testSuite         :
 **/
@IsTest
private class InboundLeadConversionPluginImplTest {
	@isTest
	static void shouldMatchExistingLead() {
		Lead testLead = new Lead(LastName = 'FooBar', Email = 'foo.bar@example.com', Brand__c = 'Boston IVF');
		insert testLead;

		InboundLead__c inboundTestLead = new InboundLead__c(Email__c = 'foo.bar@example.com', Brand__c = 'Boston IVF');
		insert inboundTestLead;

		Test.startTest();
		InboundLeadConversionPluginImpl plugin = new InboundLeadConversionPluginImpl();
		Id foundLeadId = plugin.findExistingMatchingLead(inboundTestLead);
		Test.stopTest();

		Assert.areNotEqual(null, foundLeadId, 'The lead should be found');
		Assert.areEqual(testLead.Id, foundLeadId, 'The lead should be the existing lead');
	}

	@isTest
	static void shouldNotMatchExistingLead() {
		Lead testLead = new Lead(LastName = 'FooBar', Email = 'foo.bar@example.com', Brand__c = 'Boston IVF');
		insert testLead;

		InboundLead__c inboundTestLead = new InboundLead__c(Email__c = 'bar.foo@example.com', Brand__c = 'Boston IVF');
		insert inboundTestLead;

		Test.startTest();
		InboundLeadConversionPluginImpl plugin = new InboundLeadConversionPluginImpl();
		Id foundLeadId = plugin.findExistingMatchingLead(inboundTestLead);
		Test.stopTest();

		Assert.areEqual(null, foundLeadId, 'The lead should not be found');
	}

	@isTest
	static void shouldReopenUnqualifiedLead() {
		Lead testLead = new Lead(LastName = 'FooBar', Email = 'foo.bar@example.com', Brand__c = 'Boston IVF', Status = 'Unqualified');
		insert testLead;

		InboundLead__c inboundTestLead = new InboundLead__c(Email__c = 'foo.bar@example.com', Brand__c = 'Boston IVF');
		insert inboundTestLead;

		Test.startTest();
		InboundLeadConversionPluginImpl plugin = new InboundLeadConversionPluginImpl();
		plugin.postProcess(inboundTestLead, testLead, null, null);
		Test.stopTest();

		Assert.areEqual('New', testLead.Status, 'The lead should be reopened');
	}
}
