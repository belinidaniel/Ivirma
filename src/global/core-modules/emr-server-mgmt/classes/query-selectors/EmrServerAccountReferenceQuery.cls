/**
 * @description  : Query object for EmrServerAccountReference__c records.
 * @author       : Ivo Rocha
 **/
public with sharing class EmrServerAccountReferenceQuery extends QueryObject {
	public EmrServerAccountReferenceQuery() {
		super(EmrServerAccountReference__c.SObjectType);
		withAllFields();
		withFields('EmrServer__r.Name');
	}

	public EmrServerAccountReferenceQuery byAccountId(Id accountId) {
		return byAccountId(new Set<Id>{ accountId });
	}

	public EmrServerAccountReferenceQuery byAccountId(Set<Id> accountIds) {
		return (EmrServerAccountReferenceQuery) byField(EmrServerAccountReference__c.Account__c, 'IN', accountIds);
	}

	public EmrServerAccountReferenceQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public EmrServerAccountReferenceQuery byEmrServerId(Set<Id> emrServerIds) {
		return (EmrServerAccountReferenceQuery) byField(EmrServerAccountReference__c.EmrServer__c, 'IN', emrServerIds);
	}

	public EmrServerAccountReferenceQuery byIdentifier(String identifier) {
		return byIdentifier(new Set<String>{ identifier });
	}

	public EmrServerAccountReferenceQuery byIdentifier(Set<String> identifiers) {
		return (EmrServerAccountReferenceQuery) byField(EmrServerAccountReference__c.Identifier__c, 'IN', identifiers);
	}

	public EmrServerAccountReferenceQuery byIsPrimary(Boolean isPrimary) {
		return (EmrServerAccountReferenceQuery) byField(EmrServerAccountReference__c.IsPrimary__c, '=', isPrimary);
	}
}
