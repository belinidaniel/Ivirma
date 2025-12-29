/**
 * @description  : Test class for ArtemisProvidersSyncJob.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisSyncJobs
 **/
@isTest
private class ArtemisProvidersSyncJobTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testSyncJob() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisProvidersSyncJob.executeNow();
		Test.stopTest();

		//Assert.areNotEqual(0, new ProviderQuery().getIds().size(), 'Providers should have been created'); //TODO uncomment when data processor is implemented
	}
}
