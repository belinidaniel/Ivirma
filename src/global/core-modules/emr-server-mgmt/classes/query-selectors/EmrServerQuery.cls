/**
 * @description  : Query object for EmrServer__c records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class EmrServerQuery extends QueryObject {
	public EmrServerQuery() {
		super(EmrServer__c.SObjectType);
		withAllFields();
	}
}
