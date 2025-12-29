/**
 * @description  : Query object for Patient (Account/PersonAccount) records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class PatientQuery extends QueryObject {
	public PatientQuery() {
		// Note: Account.Name should never be added in the query. Doing any update on a Person Account with the Name in the object instance will throw a DML Exception.
		super(
			new List<SObjectField>{
				Account.Id,
				Account.OwnerId,
				Account.RecordTypeId,
				Account.Salutation,
				Account.PreferredFirstName__pc,
				Account.FirstName,
				Account.MiddleName,
				Account.LastName,
				Account.Suffix,
				Account.Deceased__pc,
				Account.PersonBirthdate,
				Account.Age__pc,
				Account.SocialSecurityNumber__pc,
				Account.EmployerCompanyName__pc,
				Account.PatientCarrotPatient__c,
				Account.PatientType__c,
				Account.PatientHowDidYouHearAboutUs__c,
				Account.PatientRequestedPatientAdvocate__c,
				Account.PatientRollupBiologicalSex__c,
				Account.PatientRollupRace__c,
				Account.PatientRollupEthnicity__c,
				Account.PatientRollupGenderIdentity__c,
				Account.PatientRollupSexualOrientation__c,
				Account.PatientRollupMaritalStatus__c,
				Account.PatientRollupInterests__c,
				Account.PatientRollupLanguage__c,
				Account.PatientRollupPronouns__c
			},
			Account.SObjectType
		);
		byRecordTypeId(RecordTypes.ACCOUNT_PATIENT.Id);
	}

	public PatientQuery withErmServerReference(EmrServerAccountReference__c ermReference) {
		return withErmServerReference(new List<EmrServerAccountReference__c>{ ermReference });
	}

	public PatientQuery withErmServerReference(List<EmrServerAccountReference__c> ermReferences) {
		return (PatientQuery) relatedToChildren(ermReferences, EmrServerAccountReference__c.Account__c);
	}

	public PatientQuery bySocialSecurityNumber(String socialSecurityNumber) {
		return bySocialSecurityNumber(new Set<String>{ socialSecurityNumber });
	}

	public PatientQuery bySocialSecurityNumber(Set<String> socialSecurityNumbers) {
		return (PatientQuery) byField(Account.SocialSecurityNumber__pc, 'IN', socialSecurityNumbers);
	}

	public PatientQuery withPatientServerProfiles() {
		return (PatientQuery) withChildren(new PatientServerProfileQuery(), 'PatientServerProfiles__r');
	}
}
