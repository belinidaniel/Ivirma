/**
 * @description  : This class represents a patient's referral source in the Artemis EMR system.
 * @author       : Ivo Rocha
 **/
public class ArtemisPatientReferralSourceRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String referralSourceMetadataId;

	@InvocableVariable
	@AuraEnabled
	public String refCategory;

	@InvocableVariable
	@AuraEnabled
	public String refByPractitionerId;
}
