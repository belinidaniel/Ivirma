/**
 * @description  : Query object for Patient Server Profile records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class PatientServerProfileQuery extends QueryObject {
	public PatientServerProfileQuery() {
		super(PatientServerProfile__c.SObjectType);
		withAllFields();
		withFields(
			new List<String>{
				'PrimaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c',
				'SecondaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c',
				'TertiaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c'
			}
		);
	}

	public PatientServerProfileQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public PatientServerProfileQuery byEmrServerId(Set<Id> emrServerIds) {
		return (PatientServerProfileQuery) byField(PatientServerProfile__c.EmrServer__c, 'IN', emrServerIds);
	}

	public PatientServerProfileQuery byExternalId(String externalId) {
		return byExternalId(new Set<String>{ externalId });
	}

	public PatientServerProfileQuery byExternalId(Set<String> externalIds) {
		return (PatientServerProfileQuery) byField(PatientServerProfile__c.ArtemisPatientId__c, 'IN', externalIds);
	}
}
