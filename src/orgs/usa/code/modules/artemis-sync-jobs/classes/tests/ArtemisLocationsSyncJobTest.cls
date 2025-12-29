/**
 * @description  : Test class for ArtemisLocationsSyncJob.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisSyncJobs
 **/
@isTest
private class ArtemisLocationsSyncJobTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testSyncJob() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisLocationsSyncJob.executeNow();
		Test.stopTest();

		Assert.areNotEqual(0, new LocationQuery().getIds().size(), 'Locations should have been created');
	}
}
