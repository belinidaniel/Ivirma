/**
 * @description  : This class represents a mutation for the waiting list preferences of a new appointment in the Artemis Rest API.
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
public with sharing class ArtemisNewApptWaitingListPrefsRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public List<String> providerCalendarIds;

	@InvocableVariable
	@AuraEnabled
	public List<String> locationIds;

	@InvocableVariable
	@AuraEnabled
	public List<String> daysOfWeek;

	@InvocableVariable
	@AuraEnabled
	public String timeOfDay;

	@InvocableVariable
	@AuraEnabled
	public String comments;
}
