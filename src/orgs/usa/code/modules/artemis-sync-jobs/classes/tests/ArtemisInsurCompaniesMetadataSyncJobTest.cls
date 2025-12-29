/**
 * @description  : Test class for ArtemisInsuranceCompaniesMetadataSyncJob.
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
@isTest
private class ArtemisInsurCompaniesMetadataSyncJobTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testSyncJob() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisInsuranceCompaniesMetadataSyncJob.executeNow();
		Test.stopTest();

		Assert.areNotEqual(0, new EmrServerInsuranceCompanyMetadataQuery().getIds().size(), 'Insurance companies should have been created');
	}
}
