/**
 * @description  : This class represents an availability in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisAvailabilityRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String id;

	@InvocableVariable
	@AuraEnabled
	public String providerId;

	@InvocableVariable
	@AuraEnabled
	public String locationId;

	@InvocableVariable
	@AuraEnabled
	public DateTime startDateTime;

	@InvocableVariable
	@AuraEnabled
	public DateTime endDateTime;

	@InvocableVariable
	@AuraEnabled
	public String appointmentType;

	@InvocableVariable
	@AuraEnabled
	public String status;

	@InvocableVariable
	@AuraEnabled
	public String reservedBy;

	@InvocableVariable
	@AuraEnabled
	public DateTime reservedUntil;
}
