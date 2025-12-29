/**
 * @description  : Test class for ArtemisReferrlSourcesMetadataSyncJob.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisSyncJobs
 **/
@isTest
private class ArtemisReferrlSourcesMetadataSyncJobTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testSyncJob() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisReferralSourcesMetadataSyncJob.executeNow();
		Test.stopTest();

		Assert.areNotEqual(0, new EmrServerReferralSourceMetadataQuery().getIds().size(), 'Referral sources should have been created');
	}
}
