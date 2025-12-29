/**
 * @description  : This class represents a mutation to create a	 new appointment in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisNewAppointmentRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String slotId;

	@InvocableVariable
	@AuraEnabled
	public String patientId;

	@InvocableVariable
	@AuraEnabled
	public String scheduledBy;

	@InvocableVariable
	@AuraEnabled
	public String comments;

	@InvocableVariable
	@AuraEnabled
	public ArtemisNewApptWaitingListPrefsRestModel waitingListPreferences;
}
