/**
 * @description  : This class represents a patient in the Artemis EMR system.
 * @author       : Ivo Rocha
 **/
public class ArtemisPatientRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String id;

	@InvocableVariable
	@AuraEnabled
	public String salutation; // enum: Mr., Ms., Mrs., Dr., Prof.

	@InvocableVariable
	@AuraEnabled
	public String prefersName;

	@InvocableVariable
	@AuraEnabled
	public String firstName;

	@InvocableVariable
	@AuraEnabled
	public String middleName;

	@InvocableVariable
	@AuraEnabled
	public String lastName;

	@InvocableVariable
	@AuraEnabled
	public String suffix;

	@InvocableVariable
	@AuraEnabled
	public String socialSecurityNumber;

	@InvocableVariable
	@AuraEnabled
	public Date dateOfBirth;

	@InvocableVariable
	@AuraEnabled
	public String patientType;

	@InvocableVariable
	@AuraEnabled
	public String employer;

	@InvocableVariable
	@AuraEnabled
	public String biologicalSex; // enum: Female, Male, Unknown

	@InvocableVariable
	@AuraEnabled
	public String genderIdentity; // enum: Female, Male, Female-to-Male (FTM)/Transgender Male/Trans Man, Male-to-Female (MTF)/Transgender Female/Trans Woman, Genderqueer, neither exclusively male nor female, Unknown, Choose not to disclose, Other, please specify

	@InvocableVariable
	@AuraEnabled
	public String sexualOrientation; // enum: Straight or heterosexual, Bisexual, Lesbian, gay or homosexual, Don't know, Something else, Unknown, Choose not to disclose, Other, please specify

	@InvocableVariable
	@AuraEnabled
	public String maritalStatus; // enum: Divorced, Married, Partner, Single, Widowed, Unknown

	@InvocableVariable
	@AuraEnabled
	public String pronouns; // enum: she/her, he/him, they/them, other

	@InvocableVariable
	@AuraEnabled
	public List<String> languages; // enum: English, Spanish, Amharic, Bengali, French, German, Greek, Gujarati, Hebrew, Hindi, Italian, Japanese, Korean, Polish, Portuguese, Punjabi, Russian, Tagalog, Telugu, Urdu, Vietnamese, Armenian, Chinese, Hmong, Persian, Unknown, Other

	@InvocableVariable
	@AuraEnabled
	public String race; // enum: African American, American Indian / Alaska Native, Asian, Caucasian, Hispanic or Latino, More Than One Race, Native Hawaiian, Other Pacific Islander, Other, Refused, Unknown

	@InvocableVariable
	@AuraEnabled
	public String ethnicity; // enum: Hispanic, Non-Hispanic, White non-Hispanic, White Hispanic, Black non-Hispanic, Black Hispanic, Asian non-Hispanic, Asian Hispanic, American Indian, American Indian/Alaska Native, Asian, Black/African American, Hispanic/Latino, Native Hawaiian/Other Pacific, White/Caucasian, Asked but unknown, Not Asked, Not Provided, Refused, Refused/Choose not to disclose, Unknown, Other, Other, please specify

	@InvocableVariable
	@AuraEnabled
	public ArtemisAddressRestModel address;

	@InvocableVariable
	@AuraEnabled
	public List<String> interests; // enum: Donor Egg, Egg Freezing, Fertility Testing, IVF, IUI, LGBTQ, Tubal Ligation/Vasectomy, Self Pay, Single Parent by Choice

	@InvocableVariable
	@AuraEnabled
	public List<ArtemisPatientReferralSourceRestModel> referralSources;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPhoneNumberWithPrefRestModel phone;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPhoneNumberWithPrefRestModel mobilePhone;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPhoneNumberWithPrefRestModel homePhone;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPhoneNumberWithPrefRestModel workPhone;

	@InvocableVariable
	@AuraEnabled
	public String fax;

	@InvocableVariable
	@AuraEnabled
	public String email;

	@InvocableVariable
	@AuraEnabled
	public String additionalEmail;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPatientInsuranceRestModel primaryInsurance;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPatientInsuranceRestModel secondaryInsurance;

	@InvocableVariable
	@AuraEnabled
	public ArtemisPatientInsuranceRestModel tertiaryInsurance;

	@InvocableVariable
	@AuraEnabled
	public String partnerId;

	@InvocableVariable
	@AuraEnabled
	public String primaryLocationId;

	@InvocableVariable
	@AuraEnabled
	public String primaryDoctorId;

	/**
	 * @description  : Creates an ArtemisPatientRestModel instance from a PatientServerProfile__c object record.
	 * @param patientServerProfileRecord The PatientServerProfile__c object record to convert.
	 * @return ArtemisPatientRestModel A new ArtemisPatientRestModel instance.
	 */
	public static ArtemisPatientRestModel fromSObject(PatientServerProfile__c patientServerProfileRecord) {
		ArtemisPatientRestModel patient = new ArtemisPatientRestModel();
		patient.id = patientServerProfileRecord.ArtemisPatientId__c;
		//patient.salutation = patientServerProfileRecord.Salutation__c;
		patient.prefersName = patientServerProfileRecord.PreferredFirstName__c;
		patient.firstName = patientServerProfileRecord.FirstName__c;
		//patient.middleName = patientServerProfileRecord.MiddleName__c;
		patient.lastName = patientServerProfileRecord.LastName__c;
		patient.suffix = patientServerProfileRecord.Suffix__c;
		patient.socialSecurityNumber = patientServerProfileRecord.SocialSecurityNumber__c;
		patient.dateOfBirth = patientServerProfileRecord.Birthdate__c;
		patient.patientType = patientServerProfileRecord.PatientType__c;
		patient.employer = patientServerProfileRecord.Employer__c;
		patient.biologicalSex = patientServerProfileRecord.BiologicalSex__c;
		patient.genderIdentity = patientServerProfileRecord.GenderIdentity__c;
		patient.sexualOrientation = patientServerProfileRecord.SexualOrientation__c;
		patient.maritalStatus = patientServerProfileRecord.MaritalStatus__c;
		patient.pronouns = patientServerProfileRecord.Pronouns__c;
		patient.languages = patientServerProfileRecord.Language__c != null ? patientServerProfileRecord.Language__c.split(';') : new List<String>();
		patient.race = patientServerProfileRecord.Race__c;
		patient.ethnicity = patientServerProfileRecord.Ethnicity__c;
		patient.interests = patientServerProfileRecord.Interests__c != null ? patientServerProfileRecord.Interests__c.split(';') : new List<String>();
		patient.address = ArtemisAddressRestModel.fromSObject(patientServerProfileRecord.Address__c, true);
		patient.email = patientServerProfileRecord.Email__c;
		patient.additionalEmail = patientServerProfileRecord.AdditionalEmail__c;
		patient.fax = patientServerProfileRecord.Fax__c;
		//patient.primaryLocationId = patientServerProfileRecord.PrimaryLocation__c; //TODO
		//patient.primaryDoctorId = patientServerProfileRecord.PrimaryProvider__c; //TODO

		if (patientServerProfileRecord.Phone__c != null) {
			patient.phone = new ArtemisPhoneNumberWithPrefRestModel();
			patient.phone.phoneNumber = patientServerProfileRecord.Phone__c;
			patient.phone.eligibleForTextMessaging = patientServerProfileRecord.PhoneEligibleForTextMessages__c;
			patient.phone.eligibleForVoicemail = patientServerProfileRecord.PhoneEligibleForVoiceMail__c;
		}

		if (patientServerProfileRecord.MobilePhone__c != null) {
			patient.mobilePhone = new ArtemisPhoneNumberWithPrefRestModel();
			patient.mobilePhone.phoneNumber = patientServerProfileRecord.MobilePhone__c;
			patient.mobilePhone.eligibleForTextMessaging = patientServerProfileRecord.MobilePhoneEligibleForTextMessages__c;
			patient.mobilePhone.eligibleForVoicemail = patientServerProfileRecord.MobilePhoneEligibleForVoiceMail__c;
		}

		if (patientServerProfileRecord.HomePhone__c != null) {
			patient.homePhone = new ArtemisPhoneNumberWithPrefRestModel();
			patient.homePhone.phoneNumber = patientServerProfileRecord.HomePhone__c;
			patient.homePhone.eligibleForTextMessaging = patientServerProfileRecord.HomePhoneEligibleForTextMessages__c;
			patient.homePhone.eligibleForVoicemail = patientServerProfileRecord.HomePhoneEligibleForVoiceMail__c;
		}

		if (patientServerProfileRecord.WorkPhone__c != null) {
			patient.workPhone = new ArtemisPhoneNumberWithPrefRestModel();
			patient.workPhone.phoneNumber = patientServerProfileRecord.WorkPhone__c;
			patient.workPhone.eligibleForTextMessaging = patientServerProfileRecord.WorkPhoneEligibleForTextMessages__c;
			patient.workPhone.eligibleForVoicemail = patientServerProfileRecord.WorkPhoneEligibleForVoiceMail__c;
		}

		if (patientServerProfileRecord.PrimaryInsuranceArtemisMetadata__c != null) {
			patient.primaryInsurance = new ArtemisPatientInsuranceRestModel();
			patient.primaryInsurance.insuranceCompanyId = patientServerProfileRecord.PrimaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c;
			patient.primaryInsurance.copay = patientServerProfileRecord.PrimaryInsuranceCoPay__c;
			patient.primaryInsurance.groupNumber = patientServerProfileRecord.PrimaryInsuranceGroupNumber__c;
			patient.primaryInsurance.policyNumber = patientServerProfileRecord.PrimaryInsurancePolicyNumber__c;
			patient.primaryInsurance.effectiveDate = patientServerProfileRecord.PrimaryInsuranceEffectiveDate__c;
			patient.primaryInsurance.referralReceived = patientServerProfileRecord.PrimaryInsuranceReferralReceived__c;
			patient.primaryInsurance.referralRequired = patientServerProfileRecord.PrimaryInsuranceReferralRequired__c;
			patient.primaryInsurance.subscriber = patientServerProfileRecord.PrimaryInsuranceSubscriber__c;
		}

		if (patientServerProfileRecord.SecondaryInsuranceArtemisMetadata__c != null) {
			patient.secondaryInsurance = new ArtemisPatientInsuranceRestModel();
			patient.secondaryInsurance.insuranceCompanyId = patientServerProfileRecord.SecondaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c;
			patient.secondaryInsurance.copay = patientServerProfileRecord.SecondaryInsuranceCoPay__c;
			patient.secondaryInsurance.groupNumber = patientServerProfileRecord.SecondaryInsuranceGroupNumber__c;
			patient.secondaryInsurance.policyNumber = patientServerProfileRecord.SecondaryInsurancePolicyNumber__c;
			patient.secondaryInsurance.effectiveDate = patientServerProfileRecord.SecondaryInsuranceEffectiveDate__c;
			patient.secondaryInsurance.referralReceived = patientServerProfileRecord.SecondaryInsuranceReferralReceived__c;
			patient.secondaryInsurance.referralRequired = patientServerProfileRecord.SecondaryInsuranceReferralRequired__c;
			patient.secondaryInsurance.subscriber = patientServerProfileRecord.SecondaryInsuranceSubscriber__c;
		}

		if (patientServerProfileRecord.TertiaryInsuranceArtemisMetadata__c != null) {
			patient.tertiaryInsurance = new ArtemisPatientInsuranceRestModel();
			patient.tertiaryInsurance.insuranceCompanyId = patientServerProfileRecord.TertiaryInsuranceArtemisMetadata__r.InsuranceCompanyInternalId__c;
			patient.tertiaryInsurance.copay = patientServerProfileRecord.TertiaryInsuranceCoPay__c;
			patient.tertiaryInsurance.groupNumber = patientServerProfileRecord.TertiaryInsuranceGroupNumber__c;
			patient.tertiaryInsurance.policyNumber = patientServerProfileRecord.TertiaryInsurancePolicyNumber__c;
			patient.tertiaryInsurance.effectiveDate = patientServerProfileRecord.TertiaryInsuranceEffectiveDate__c;
			patient.tertiaryInsurance.referralReceived = patientServerProfileRecord.TertiaryInsuranceReferralReceived__c;
			patient.tertiaryInsurance.referralRequired = patientServerProfileRecord.TertiaryInsuranceReferralRequired__c;
			patient.tertiaryInsurance.subscriber = patientServerProfileRecord.TertiaryInsuranceSubscriber__c;
		}

		//TODO: Add referral sources

		return patient;
	}

	/**
	 * @description  : Converts the current ArtemisPatientRestModel instance to a PatientServerProfile__c object record.
	 * @return PatientServerProfile__c A new PatientServerProfile__c object record.
	 */
	public PatientServerProfile__c toSObject() {
		return toSObject(null, null);
	}

	/**
	 * @description  : Converts the current ArtemisPatientRestModel instance to a PatientServerProfile__c object record.
	 * @param recordId The Id of the PatientServerProfile__c object record, if existing.
	 * @return PatientServerProfile__c A new PatientServerProfile__c object record.
	 */
	public PatientServerProfile__c toSObject(Id recordId) {
		return toSObject(recordId, null);
	}

	/**
	 * @description  : Converts the current ArtemisPatientRestModel instance to a PatientServerProfile__c object record.
	 * @param recordId The Id of the PatientServerProfile__c object record, if existing.
	 * @param contextRefs The context references for the PatientServerProfile__c object record.
	 * @return PatientServerProfile__c A new PatientServerProfile__c object record.
	 */
	public PatientServerProfile__c toSObject(Id recordId, ToSObjectContextRefs contextRefs) {
		PatientServerProfile__c patientServerProfile = new PatientServerProfile__c(Id = recordId);
		patientServerProfile.ArtemisPatientId__c = this.id;
		//patientServerProfile.EmrServer__c = this.emrServer;
		//patientServerProfile.Patient__c = this.patientId;
		patientServerProfile.PreferredFirstName__c = this.prefersName;
		patientServerProfile.FirstName__c = this.firstName;
		patientServerProfile.LastName__c = this.lastName;
		//patientServerProfile.MiddleName__c = this.middleName;
		patientServerProfile.Suffix__c = this.suffix;
		patientServerProfile.Birthdate__c = this.dateOfBirth;
		patientServerProfile.GenderIdentity__c = this.genderIdentity;
		patientServerProfile.SexualOrientation__c = this.sexualOrientation;
		//patientServerProfile.MaritalStatus__c = this.maritalStatus;
		patientServerProfile.Pronouns__c = this.pronouns;
		patientServerProfile.Language__c = this.languages != null ? String.join(this.languages, ';') : null;
		patientServerProfile.Race__c = this.race;
		patientServerProfile.Ethnicity__c = this.ethnicity;
		patientServerProfile.Fax__c = this.fax;
		patientServerProfile.Email__c = this.email;
		patientServerProfile.AdditionalEmail__c = this.additionalEmail;
		patientServerProfile.Interests__c = this.interests != null ? String.join(this.interests, ';') : null;
		patientServerProfile.Employer__c = this.employer;
		patientServerProfile.BiologicalSex__c = this.biologicalSex;
		patientServerProfile.PatientType__c = this.patientType;
		patientServerProfile.SocialSecurityNumber__c = this.socialSecurityNumber;
		//patientServerProfile.CareTeamObGynProvider__c = null; //TODO
		//patientServerProfile.CareTeamPcpProvider__c = null; //TODO
		patientServerProfile.PrimaryLocation__c = contextRefs?.sfPrimaryLocationId;
		patientServerProfile.PrimaryProvider__c = contextRefs?.sfPrimaryDoctorId;

		if (this.address != null) {
			patientServerProfile.Address__Street__s = this.address.street;
			patientServerProfile.Address__City__s = this.address.city;
			patientServerProfile.Address__PostalCode__s = this.address.zip;
			patientServerProfile.Address__StateCode__s = this.address.stateCode;
			patientServerProfile.Address__CountryCode__s = this.address.countryCode;
		}

		if (this.phone != null) {
			patientServerProfile.Phone__c = this.phone.phoneNumber;
			patientServerProfile.PhoneEligibleForTextMessages__c = this.phone.eligibleForTextMessaging;
			patientServerProfile.PhoneEligibleForVoiceMail__c = this.phone.eligibleForVoicemail;
		}

		if (this.mobilePhone != null) {
			patientServerProfile.MobilePhone__c = this.mobilePhone.phoneNumber;
			patientServerProfile.MobilePhoneEligibleForTextMessages__c = this.mobilePhone.eligibleForTextMessaging;
			patientServerProfile.MobilePhoneEligibleForVoiceMail__c = this.mobilePhone.eligibleForVoicemail;
		}

		if (this.homePhone != null) {
			patientServerProfile.HomePhone__c = this.homePhone.phoneNumber;
			patientServerProfile.HomePhoneEligibleForTextMessages__c = this.homePhone.eligibleForTextMessaging;
			patientServerProfile.HomePhoneEligibleForVoiceMail__c = this.homePhone.eligibleForVoicemail;
		}

		if (this.workPhone != null) {
			patientServerProfile.WorkPhone__c = this.workPhone.phoneNumber;
			patientServerProfile.WorkPhoneEligibleForTextMessages__c = this.workPhone.eligibleForTextMessaging;
			patientServerProfile.WorkPhoneEligibleForVoiceMail__c = this.workPhone.eligibleForVoicemail;
		}

		if (this.primaryInsurance != null) {
			patientServerProfile.PrimaryInsuranceArtemisMetadata__c = contextRefs?.sfPrimaryInsuranceCompanyMetadataId;
			patientServerProfile.PrimaryInsuranceCoPay__c = this.primaryInsurance.copay;
			patientServerProfile.PrimaryInsuranceGroupNumber__c = this.primaryInsurance.groupNumber;
			patientServerProfile.PrimaryInsurancePolicyNumber__c = this.primaryInsurance.policyNumber;
			patientServerProfile.PrimaryInsuranceEffectiveDate__c = this.primaryInsurance.effectiveDate;
			patientServerProfile.PrimaryInsuranceReferralReceived__c = getSafeBoolean(this.primaryInsurance.referralReceived);
			patientServerProfile.PrimaryInsuranceReferralRequired__c = getSafeBoolean(this.primaryInsurance.referralRequired);
			patientServerProfile.PrimaryInsuranceSubscriber__c = this.primaryInsurance.subscriber;
		}

		if (this.secondaryInsurance != null) {
			patientServerProfile.SecondaryInsuranceArtemisMetadata__c = contextRefs?.sfSecondaryInsuranceCompanyMetadataId;
			patientServerProfile.SecondaryInsuranceCoPay__c = this.secondaryInsurance.copay;
			patientServerProfile.SecondaryInsuranceGroupNumber__c = this.secondaryInsurance.groupNumber;
			patientServerProfile.SecondaryInsurancePolicyNumber__c = this.secondaryInsurance.policyNumber;
			patientServerProfile.SecondaryInsuranceEffectiveDate__c = this.secondaryInsurance.effectiveDate;
			patientServerProfile.SecondaryInsuranceReferralReceived__c = getSafeBoolean(this.secondaryInsurance.referralReceived);
			patientServerProfile.SecondaryInsuranceReferralRequired__c = getSafeBoolean(this.secondaryInsurance.referralRequired);
			patientServerProfile.SecondaryInsuranceSubscriber__c = this.secondaryInsurance.subscriber;
		}

		if (this.tertiaryInsurance != null) {
			patientServerProfile.TertiaryInsuranceArtemisMetadata__c = contextRefs?.sfTertiaryInsuranceCompanyMetadataId;
			patientServerProfile.TertiaryInsuranceCoPay__c = this.tertiaryInsurance.copay;
			patientServerProfile.TertiaryInsuranceGroupNumber__c = this.tertiaryInsurance.groupNumber;
			patientServerProfile.TertiaryInsurancePolicyNumber__c = this.tertiaryInsurance.policyNumber;
			patientServerProfile.TertiaryInsuranceEffectiveDate__c = this.tertiaryInsurance.effectiveDate;
			patientServerProfile.TertiaryInsuranceReferralReceived__c = getSafeBoolean(this.tertiaryInsurance.referralReceived);
			patientServerProfile.TertiaryInsuranceReferralRequired__c = getSafeBoolean(this.tertiaryInsurance.referralRequired);
			patientServerProfile.TertiaryInsuranceSubscriber__c = this.tertiaryInsurance.subscriber;
		}

		return patientServerProfile;
	}

	public class ToSObjectContextRefs {
		public Id sfPrimaryInsuranceCompanyMetadataId { get; set; }
		public Id sfSecondaryInsuranceCompanyMetadataId { get; set; }
		public Id sfTertiaryInsuranceCompanyMetadataId { get; set; }
		public Id sfPrimaryLocationId { get; set; }
		public Id sfPrimaryDoctorId { get; set; }
	}
}
