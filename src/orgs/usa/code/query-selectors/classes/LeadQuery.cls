/**
 * @description  : Query object for Lead records.
 * @author       : Daniel Belini
 **/
public with sharing class LeadQuery extends QueryObject {
	public LeadQuery() {
		super(Lead.SObjectType);
		withAllFields();
	}

	public LeadQuery byEmail(String emails) {
		return byEmail(new Set<String>{ emails });
	}

	public LeadQuery byEmail(Set<String> emails) {
		return (LeadQuery) byField(Lead.Email, 'IN', emails);
	}

	public LeadQuery byBrand(String emails) {
		return byBrand(new Set<String>{ emails });
	}

	public LeadQuery byBrand(Set<String> emails) {
		return (LeadQuery) byField(Lead.Brand__c, 'IN', emails);
	}
}
