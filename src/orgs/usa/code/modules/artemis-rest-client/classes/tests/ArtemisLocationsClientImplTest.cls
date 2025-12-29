/**
 * @description  : Test class for the Artemis Locations Client implementation.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisLocationsClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldGetLocation() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisLocationRestModel location = ArtemisRestClientTest.getTestRestClientInstance().locations.getLocation('1234');
		Test.stopTest();

		Assert.isNotNull(location, 'Location should not be null');
		Assert.isNotNull(location.id, 'Location id should not be empty');
	}

	@isTest
	static void shouldFailGettingLocationWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().locations.getLocation(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldGetLocations() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		List<ArtemisLocationRestModel> locations = ArtemisRestClientTest.getTestRestClientInstance().locations.getLocations();
		Test.stopTest();

		Assert.isNotNull(locations, 'Locations should not be null');
		Assert.isTrue(locations.size() > 0, 'Locations should not be empty');
		Assert.isNotNull(locations[0].id, 'First location id should not be empty');
	}
}
