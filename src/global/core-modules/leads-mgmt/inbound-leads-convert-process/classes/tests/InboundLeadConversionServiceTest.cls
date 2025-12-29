/**
 * @description  : Test class for InboundLeadConversionService.
 * @author       : Ivo Rocha
 * @testSuite    : InboundLeadsProcessing
 **/
@IsTest
private class InboundLeadConversionServiceTest {
	@IsTest
	static void testProcessInboundLeads() {
		InboundLead__c inboundLead = new InboundLead__c(
			Email__c = 'john.doe@example.com',
			FirstName__c = 'John',
			LastName__c = 'Doe',
			AddressStateCode__c = 'NY'
		);
		insert inboundLead;

		Test.startTest();
		InboundLeadConversionService.process(new List<Id>{ inboundLead.Id });
		Test.stopTest();

		Assert.areEqual(1, [SELECT COUNT() FROM Lead], 'One lead should be created');
		Assert.areEqual(1, [SELECT COUNT() FROM LeadInteractionEntry__c], 'One lead interaction entry should be created');
	}
}
