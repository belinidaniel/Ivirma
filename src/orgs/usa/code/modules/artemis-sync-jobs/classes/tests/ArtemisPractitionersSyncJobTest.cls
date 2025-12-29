/**
 * @description  : Test class for ArtemisPractitionersSyncJob.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisSyncJobs
 **/
@isTest
private class ArtemisPractitionersSyncJobTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testSyncJob() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisPractitionersSyncJob.executeNow();
		Test.stopTest();

		//Assert.areNotEqual(0, new ProviderQuery().getIds().size(), 'Practitioners should have been created'); //TODO uncomment when data processor is implemented
	}
}
