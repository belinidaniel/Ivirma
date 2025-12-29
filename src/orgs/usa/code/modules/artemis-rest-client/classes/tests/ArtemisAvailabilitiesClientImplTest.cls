/**
 * @description  : Test class for the Artemis Availabilities Client implementation.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisAvailabilitiesClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldSearchAvailabilities() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		Map<String, Object> filters = new Map<String, Object>();
		filters.put('locationIds', new List<String>{ '1' });
		filters.put('providerIds', new List<String>{ '1' });
		filters.put('appointmentType', 'Telehealth');
		filters.put('startDate', DateTime.now());
		filters.put('endDate', Date.today().addDays(7));

		List<ArtemisAvailabilityRestModel> availabilities = ArtemisRestClientTest.getTestRestClientInstance().availabilities.searchAvailabilities(filters);
		Test.stopTest();

		Assert.isNotNull(availabilities, 'Fetched availabilities should not be null');
		Assert.isTrue(availabilities.size() > 0, 'Fetched availabilities should not be empty');
	}

	@isTest
	static void shouldReserveAvailability() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		EmrRestClient.RestModel response = ArtemisRestClientTest.getTestRestClientInstance().availabilities.reserveAvailability('1');
		Test.stopTest();

		Assert.isNotNull(response, 'Response should not be null');
	}

	@isTest
	static void shouldFailReservingAvailabilityWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().availabilities.reserveAvailability(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldReleaseAvailability() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		EmrRestClient.RestModel response = ArtemisRestClientTest.getTestRestClientInstance().availabilities.releaseAvailability('1');
		Test.stopTest();

		Assert.isNotNull(response, 'Response should not be null');
	}

	@isTest
	static void shouldFailReleasingAvailabilityWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().availabilities.releaseAvailability(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}
}
