/**
 * @description  : This class is used to query the EmrServerInsuranceCompanyMetadata__c object.
 * @author       : Ivo Rocha
 **/
public inherited sharing class EmrServerInsuranceCompanyMetadataQuery extends QueryObject {
	public EmrServerInsuranceCompanyMetadataQuery() {
		super(
			new List<SObjectField>{
				EmrServerInsuranceCompanyMetadata__c.Id,
				EmrServerInsuranceCompanyMetadata__c.Name,
				EmrServerInsuranceCompanyMetadata__c.EmrServer__c,
				EmrServerInsuranceCompanyMetadata__c.InsuranceCompanyInternalId__c
			},
			EmrServerInsuranceCompanyMetadata__c.SObjectType
		);
	}

	public EmrServerInsuranceCompanyMetadataQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public EmrServerInsuranceCompanyMetadataQuery byEmrServerId(Set<Id> emrServerIds) {
		return (EmrServerInsuranceCompanyMetadataQuery) byField(EmrServerInsuranceCompanyMetadata__c.EmrServer__c, 'IN', emrServerIds);
	}

	public EmrServerInsuranceCompanyMetadataQuery byExternalId(String externalId) {
		return byExternalId(new Set<String>{ externalId });
	}

	public EmrServerInsuranceCompanyMetadataQuery byExternalId(Set<String> externalIds) {
		return (EmrServerInsuranceCompanyMetadataQuery) byField(EmrServerInsuranceCompanyMetadata__c.InsuranceCompanyInternalId__c, 'IN', externalIds);
	}
}
