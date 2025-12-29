/**
 * @description  : Test class for RecordTypes class
 * @author       : Ivo Rocha
 **/
@IsTest(IsParallel=true)
private class RecordTypesTest {
	@IsTest
	static void shouldRetrieveRecordTypeId() {
		Assert.isNotNull(RecordTypes.ACCOUNT_PATIENT?.Id, 'RecordTypeId should not be null');
		Assert.isNotNull(RecordTypes.ACCOUNT_BUSINESS?.Id, 'RecordTypeId should not be null');
		Assert.isNotNull(RecordTypes.ACCOUNT_LOCATION?.Id, 'RecordTypeId should not be null');
	}
}
