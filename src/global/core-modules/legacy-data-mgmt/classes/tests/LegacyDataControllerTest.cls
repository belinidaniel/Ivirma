/**
 * @description  : This class is responsible for testing the LegacyDataController class, specifically the getLegacyData method.
 * @author       : Ivo Rocha
 **/
@isTest
private class LegacyDataControllerTest {
	@TestSetup
	static void makeData() {
		// Create a test record for LegacyDataEntry__c
		LegacyDataEntry__c testEntry = new LegacyDataEntry__c(
			FieldName__c = 'TestField',
			FieldValue__c = 'TestValue',
			SourceEntityId__c = '003bc00000FklUjAAJ'
		);
		insert testEntry;
	}

	@isTest
	static void testGetLegacyData() {
		Test.startTest();
		List<LegacyDataEntry__c> result = LegacyDataController.getLegacyData('003bc00000FklUjAAJ');
		Test.stopTest();

		System.assertEquals(1, result.size(), 'Expected one legacy data entry to be returned.');
		System.assertEquals('TestField', result[0].FieldName__c, 'Field names do not match.');
		System.assertEquals('TestValue', result[0].FieldValue__c, 'Field values do not match.');
	}
}
