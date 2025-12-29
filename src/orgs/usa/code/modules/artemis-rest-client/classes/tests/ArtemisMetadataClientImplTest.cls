/**
 * @description  : Test class for the ArtemisMetadataClientImpl class.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisMetadataClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldGetInsuranceCompaniesMetadata() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		List<ArtemisMetadataInsuranceCompanyRestModel> insuranceCompaniesMetadata = ArtemisRestClientTest.getTestRestClientInstance()
			.metadata.getInsuranceCompanies();
		Test.stopTest();

		Assert.isNotNull(insuranceCompaniesMetadata, 'Insurance companies should not be null');
		Assert.isTrue(insuranceCompaniesMetadata.size() > 0, 'Insurance companies should not be empty');
		Assert.isNotNull(insuranceCompaniesMetadata[0].id, 'First insurance company id should not be empty');
	}

	@isTest
	static void shouldGetReferralSourcesMetadata() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		List<ArtemisMetadataReferralSourceRestModel> referralSourcesMetadata = ArtemisRestClientTest.getTestRestClientInstance().metadata.getReferralSources();
		Test.stopTest();

		Assert.isNotNull(referralSourcesMetadata, 'Referral sources should not be null');
		Assert.isTrue(referralSourcesMetadata.size() > 0, 'Referral sources should not be empty');
		Assert.isNotNull(referralSourcesMetadata[0].id, 'First referral source id should not be empty');
	}
}
