/**
 * @description  : Test class for the Artemis Appointments Client implementation.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisAppointmentsClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldGetAppointment() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisAppointmentRestModel appointment = ArtemisRestClientTest.getTestRestClientInstance().appointments.getAppointment('1');
		Test.stopTest();

		Assert.isNotNull(appointment, 'Fetched appointment should not be null');
		Assert.isNotNull(appointment.id, 'Fetched appointment id should not be empty');
	}

	@isTest
	static void shouldFailGettingAppointmentWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().appointments.getAppointment(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldCreateAppointment() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisNewAppointmentRestModel appointment = new ArtemisNewAppointmentRestModel();
		appointment.patientId = '1';
		appointment.slotId = '1';

		Test.startTest();
		ArtemisAppointmentRestModel appointmentCreated = ArtemisRestClientTest.getTestRestClientInstance().appointments.createAppointment(appointment);
		Test.stopTest();

		Assert.isNotNull(appointmentCreated, 'Created appointment should not be null');
		Assert.isNotNull(appointmentCreated.id, 'Created appointment id should not be empty');
	}

	@isTest
	static void shouldFailCreatingAppointmentWithoutRequiredInformation() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		// Test case for null appointment
		try {
			ArtemisRestClientTest.getTestRestClientInstance().appointments.createAppointment(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}

		// Test case for missing patientId
		try {
			ArtemisNewAppointmentRestModel appointment = new ArtemisNewAppointmentRestModel();
			appointment.slotId = '1';
			ArtemisRestClientTest.getTestRestClientInstance().appointments.createAppointment(appointment);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}

		// Test case for missing slotId
		try {
			ArtemisNewAppointmentRestModel appointment = new ArtemisNewAppointmentRestModel();
			appointment.patientId = '1';
			ArtemisRestClientTest.getTestRestClientInstance().appointments.createAppointment(appointment);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldCancelAppointment() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisCancelAppointmentRestModel cancelRequest = new ArtemisCancelAppointmentRestModel();
		cancelRequest.reason = 'Test cancellation';
		cancelRequest.cancelledBy = 'Test User';

		Test.startTest();
		EmrRestClient.RestModel response = ArtemisRestClientTest.getTestRestClientInstance().appointments.cancelAppointment('1', cancelRequest);
		Test.stopTest();

		Assert.isNotNull(response, 'Cancellation response should not be null');
	}

	@isTest
	static void shouldFailCancellingAppointmentWithoutRequiredInformation() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		// Test case for missing appointmentId
		try {
			ArtemisCancelAppointmentRestModel cancelRequest = new ArtemisCancelAppointmentRestModel();
			cancelRequest.reason = 'Test cancellation';
			cancelRequest.cancelledBy = 'Test User';
			ArtemisRestClientTest.getTestRestClientInstance().appointments.cancelAppointment(null, cancelRequest);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}

		// Test case for missing cancelRequest parameter
		try {
			ArtemisRestClientTest.getTestRestClientInstance().appointments.cancelAppointment('1', null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}
}
