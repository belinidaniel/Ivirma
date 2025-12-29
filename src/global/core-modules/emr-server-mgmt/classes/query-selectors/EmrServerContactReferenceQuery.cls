/**
 * @description  : Query object for EmrServerContactReference__c records.
 * @author       : Ivo Rocha
 **/
public with sharing class EmrServerContactReferenceQuery extends QueryObject {
	public EmrServerContactReferenceQuery() {
		super(EmrServerContactReference__c.SObjectType);
		withAllFields();
		withFields('EmrServer__r.Name');
	}

	public EmrServerContactReferenceQuery byContactId(Contact contact) {
		return byContactId(new Set<Id>{ contact.Id });
	}

	public EmrServerContactReferenceQuery byContactId(List<Contact> contacts) {
		Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
		return byContactId(contactMap.keySet());
	}

	public EmrServerContactReferenceQuery byContactId(Id contactId) {
		return byContactId(new Set<Id>{ contactId });
	}

	public EmrServerContactReferenceQuery byContactId(Set<Id> contactIds) {
		return (EmrServerContactReferenceQuery) byField(EmrServerContactReference__c.Contact__c, 'IN', contactIds);
	}

	public EmrServerContactReferenceQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public EmrServerContactReferenceQuery byEmrServerId(Set<Id> emrServerIds) {
		return (EmrServerContactReferenceQuery) byField(EmrServerContactReference__c.EmrServer__c, 'IN', emrServerIds);
	}

	public EmrServerContactReferenceQuery byIdentifier(String identifier) {
		return byIdentifier(new Set<String>{ identifier });
	}

	public EmrServerContactReferenceQuery byIdentifier(Set<String> identifiers) {
		return (EmrServerContactReferenceQuery) byField(EmrServerContactReference__c.Identifier__c, 'IN', identifiers);
	}
}
