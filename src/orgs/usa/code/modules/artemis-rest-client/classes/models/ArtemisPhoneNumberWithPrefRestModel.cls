/**
 * @description  : This class represents a phone number with preferences for text messaging and voicemail.
 * @author       : Ivo Rocha
 **/
public class ArtemisPhoneNumberWithPrefRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String phoneNumber;

	@InvocableVariable
	@AuraEnabled
	public Boolean eligibleForTextMessaging;

	@InvocableVariable
	@AuraEnabled
	public Boolean eligibleForVoicemail;
}
