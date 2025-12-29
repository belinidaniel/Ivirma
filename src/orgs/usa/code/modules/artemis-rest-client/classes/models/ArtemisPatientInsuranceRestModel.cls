/**
 * @description  : This class represents a patient's insurance in the Artemis EMR system.
 * @author       : Ivo Rocha
 **/
public class ArtemisPatientInsuranceRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String insuranceCompanyId;

	@InvocableVariable
	@AuraEnabled
	public String groupNumber;

	@InvocableVariable
	@AuraEnabled
	public String policyNumber;

	@InvocableVariable
	@AuraEnabled
	public Date effectiveDate;

	@InvocableVariable
	@AuraEnabled
	public String copay;

	@InvocableVariable
	@AuraEnabled
	public String subscriber;

	@InvocableVariable
	@AuraEnabled
	public Boolean referralRequired;

	@InvocableVariable
	@AuraEnabled
	public Boolean referralReceived;
}
