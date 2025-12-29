/**
 * @description  : Test class for the Artemis Practitioners Client implementation.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisRestClient
 **/
@isTest
private class ArtemisPractitionersClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldGetPractitioner() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisPractitionerRestModel practitioner = ArtemisRestClientTest.getTestRestClientInstance().practitioners.getPractitioner('1234');
		Test.stopTest();

		Assert.isNotNull(practitioner, 'Practitioner should not be null');
		Assert.isNotNull(practitioner.id, 'Practitioner id should not be empty');
	}

	@isTest
	static void shouldGetPractitioners() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		List<ArtemisPractitionerRestModel> practitioners = ArtemisRestClientTest.getTestRestClientInstance().practitioners.getPractitioners();
		Test.stopTest();

		Assert.isNotNull(practitioners, 'Practitioners should not be null');
		Assert.isTrue(practitioners.size() > 0, 'Practitioners should not be empty');
		Assert.isNotNull(practitioners[0].id, 'First practitioner id should not be empty');
	}
}
