/**
 * @description  : Test class for PermissionSets class
 * @author       : Ivo Rocha
**/
@IsTest(IsParallel=true)
private class PermissionSetsTest {

    @IsTest
    static void shouldCacheQueryResultsToPreserveLimits() {
        PermissionSet managePatients = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ManagePatients'];

        Test.startTest();
        System.assertEquals(managePatients.Id, PermissionSets.MANAGE_PATIENTS.Id);
        System.assertEquals(managePatients.Name, PermissionSets.MANAGE_PATIENTS.Name);
        System.assertEquals(1, Limits.getQueries(), 'Consecutive calls should not use more queries');
        Test.stopTest();
    }

    @IsTest
    static void coverageTest() {
        System.assertNotEquals(null, PermissionSets.MANAGE_PATIENTS.Id);
        //TODO
    }
}