/**
 * @description  : This class is responsible for managing legacy data entries in the system, used by the LWC 'legacyDataDisplay' component.
 * @author       : Ivo Rocha
 * @testClass    : LegacyDataControllerTest
 **/
public with sharing class LegacyDataController {
	@AuraEnabled(cacheable=true)
	public static List<LegacyDataEntry__c> getLegacyData(Id recordId) {
		return [SELECT FieldName__c, FieldValue__c FROM LegacyDataEntry__c WHERE SourceEntityId__c = :recordId];
	}
}
