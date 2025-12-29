/**
 * @description  : Test class for Profiles class   
 * @author       : Ivo Rocha
**/
@IsTest(IsParallel=true)
private class ProfilesTest {

    @IsTest
    static void shouldCacheQueryResultsToPreserveLimits() {
        Profile sysAdmin = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

        Test.startTest();
        System.assertEquals(sysAdmin.Id, Profiles.SYSTEM_ADMINISTRATOR.Id);
        System.assertEquals(sysAdmin.Name, Profiles.SYSTEM_ADMINISTRATOR.Name);
        System.assertEquals(1, Limits.getQueries(), 'Consecutive calls should not use more queries');
        Test.stopTest();
    }

    @IsTest
    static void coverageTest() {
        System.assertNotEquals(null, Profiles.SYSTEM_ADMINISTRATOR.Id);
        //TODO
    }
}