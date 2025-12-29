/**
 * @description  : Query object for LeadInteractionEntry__c
 * @author       : Ivo Rocha
 * @testClass    : LeadInteractionEntryQueryTest
 **/
public inherited sharing class LeadInteractionEntryQuery extends QueryObject {
	public LeadInteractionEntryQuery() {
		super(LeadInteractionEntry__c.SObjectType);
		withAllFields();
	}

	public LeadInteractionEntryQuery byLeadId(Id leadId) {
		return byLeadId(new Set<Id>{ leadId });
	}

	public LeadInteractionEntryQuery byLeadId(Set<Id> leadIds) {
		return (LeadInteractionEntryQuery) byField(LeadInteractionEntry__c.Lead__c, 'IN', leadIds);
	}
}
