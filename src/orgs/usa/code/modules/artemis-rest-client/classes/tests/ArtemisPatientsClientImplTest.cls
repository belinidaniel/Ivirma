/**
 * @description  : Test class for the Artemis Patients Client implementation.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
private class ArtemisPatientsClientImplTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldFailFindingPatient_MethodNotImplemeted() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().patients.findPatient(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldCreatePatient() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisPatientRestModel patient = new ArtemisPatientRestModel();
		patient.firstName = 'John';

		Test.startTest();
		ArtemisPatientRestModel patientCreated = ArtemisRestClientTest.getTestRestClientInstance().patients.createPatient(patient);
		Test.stopTest();

		Assert.isNotNull(patientCreated, 'Patient should not be null');
		Assert.isNotNull(patientCreated.id, 'Patient id should not be empty');
		Assert.isNotNull(patientCreated.firstName, 'Patient first name should not be empty');
	}

	@isTest
	static void shouldFailCreatingEmptyPatient() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().patients.createPatient(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldUpdatePatient() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisPatientRestModel patient = new ArtemisPatientRestModel();
		patient.id = '1';
		patient.firstName = 'John';

		Test.startTest();
		ArtemisPatientRestModel patientUpdated = ArtemisRestClientTest.getTestRestClientInstance().patients.updatePatient(patient);
		Test.stopTest();

		Assert.isNotNull(patientUpdated, 'Patient should not be null');
		Assert.isNotNull(patientUpdated.id, 'Patient id should not be empty');
		Assert.isNotNull(patientUpdated.firstName, 'Patient first name should not be empty');
	}

	@isTest
	static void shouldFailUpdatingEmptyPatient() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().patients.updatePatient(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldFailUpdatingPatientWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisPatientRestModel patient = new ArtemisPatientRestModel();
		patient.id = null;
		patient.firstName = 'John';

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().patients.updatePatient(patient);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldGetPatient() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		ArtemisPatientRestModel patient = ArtemisRestClientTest.getTestRestClientInstance().patients.getPatient('1');
		Test.stopTest();

		Assert.isNotNull(patient, 'Patient should not be null');
		Assert.isNotNull(patient.id, 'Patient id should not be empty');
		Assert.isNotNull(patient.firstName, 'Patient first name should not be empty');
	}

	@isTest
	static void shouldFailGettingPatientWithoutId() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		Test.startTest();
		try {
			ArtemisRestClientTest.getTestRestClientInstance().patients.getPatient(null);
			Assert.fail('Expected exception not thrown');
		} catch (EmrRestClientException e) {
			Assert.isNotNull(e.getMessage());
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}
}
