/**
 * @description  : Unit tests for ArtemisAppointmentsDataProcessor
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
@isTest
private class ArtemisAppointmentsDataProcessorTest {
	@TestSetup
	static void makeData() {
		EmrServer__c emrServer = new EmrServer__c(
			Name = 'XPTO',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
		);
		insert emrServer;

		Account patient = new Account(RecordTypeId = RecordTypes.ACCOUNT_PATIENT.id, FirstName = 'Foo', LastName = 'Bar');
		insert patient;

		EmrServerAccountReference__c ermPatientReference = new EmrServerAccountReference__c(
			EmrServer__c = emrServer.Id,
			Account__c = patient.Id,
			Identifier__c = '12345',
			IsPrimary__c = true
		);
		insert ermPatientReference;

		Contact provider = new Contact(RecordTypeId = RecordTypes.CONTACT_PROVIDER.id, FirstName = 'Provider Foo', LastName = 'Provider Bar');
		insert provider;

		EmrServerContactReference__c ermProviderReference = new EmrServerContactReference__c(
			EmrServer__c = emrServer.Id,
			Contact__c = provider.Id,
			Identifier__c = '1001'
		);
		insert ermProviderReference;

		Account location = new Account(
			RecordTypeId = RecordTypes.ACCOUNT_LOCATION.id,
			Name = 'Location Foo Bar',
			LocationEmrServer__c = emrServer.Id,
			LocationArtemisExternalId__c = '2002'
		);
		insert location;

		Appointment__c appointment = new Appointment__c(
			EmrServer__c = emrServer.Id,
			EmrAppointmentId__c = '00001',
			Patient__c = patient.Id,
			Provider__c = provider.Id,
			Location__c = location.Id,
			AppointmentType__c = 'New Patient',
			Status__c = 'Scheduled',
			AppointmentDateTime__c = DateTime.now()
		);
		insert appointment;
	}

	@isTest
	static void shouldCreateNewAppointment() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisAppointmentRestModel payloadModel = new ArtemisAppointmentRestModel();
		payloadModel.id = '12345';
		payloadModel.patientId = '12345';
		payloadModel.providerId = '1001';
		payloadModel.locationId = '2002';
		payloadModel.appointmentType = 'New Patient';
		payloadModel.appointmentStatus = 'Scheduled';
		payloadModel.appointmentDateTime = DateTime.now();

		ArtemisAppointmentsDataProcessor processor = new ArtemisAppointmentsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'The result should be successful');

		Assert.areEqual(2, new AppointmentQuery().getCount(), 'There should be two appointments in the database');
		Appointment__c appointment = (Appointment__c) new AppointmentQuery()
			.byEmrServerId(emrServer.emrServerId)
			.byExternalId(new Set<String>{ payloadModel.id })
			.getFirstOrNull();

		Assert.areEqual(payloadModel.id, appointment.EmrAppointmentId__c, 'The appointment should have the correct id');
		Assert.isNotNull(appointment.Patient__c, 'The appointment should have a patient');
		Assert.areEqual(payloadModel.patientId, appointment.RawPatientId__c, 'The appointment should have the correct patient id');
		Assert.isNotNull(appointment.Provider__c, 'The appointment should have a provider');
		Assert.areEqual(payloadModel.providerId, appointment.RawProviderId__c, 'The appointment should have the correct provider id');
		Assert.isNotNull(appointment.Location__c, 'The appointment should have a location');
		Assert.areEqual(payloadModel.locationId, appointment.RawLocationId__c, 'The appointment should have the correct location id');
		Assert.areEqual(payloadModel.appointmentType, appointment.AppointmentType__c, 'The appointment should have the correct type');
		Assert.areEqual(payloadModel.appointmentStatus, appointment.Status__c, 'The appointment should have the correct status');
	}

	@isTest
	static void shouldUpdateExistingAppointment() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		ArtemisAppointmentRestModel payloadModel = new ArtemisAppointmentRestModel();
		payloadModel.id = '00001';
		payloadModel.patientId = '12345';
		payloadModel.providerId = '1001';
		payloadModel.locationId = '2002';
		payloadModel.appointmentType = 'New Patient';
		payloadModel.appointmentStatus = 'Scheduled';
		payloadModel.appointmentDateTime = DateTime.now();

		ArtemisAppointmentsDataProcessor processor = new ArtemisAppointmentsDataProcessor();
		processor.add(emrServer, payloadModel);

		Test.startTest();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'The result should be successful');

		Assert.areEqual(1, new AppointmentQuery().getCount(), 'There should be there only one appointment in the database');
		Appointment__c appointment = (Appointment__c) new AppointmentQuery()
			.byEmrServerId(emrServer.emrServerId)
			.byExternalId(new Set<String>{ payloadModel.id })
			.getFirstOrNull();

		Assert.areEqual(payloadModel.id, appointment.EmrAppointmentId__c, 'The appointment should have the correct id');
		Assert.isNotNull(appointment.Patient__c, 'The appointment should have a patient');
		Assert.areEqual(payloadModel.patientId, appointment.RawPatientId__c, 'The appointment should have the correct patient id');
		Assert.isNotNull(appointment.Provider__c, 'The appointment should have a provider');
		Assert.areEqual(payloadModel.providerId, appointment.RawProviderId__c, 'The appointment should have the correct provider id');
		Assert.isNotNull(appointment.Location__c, 'The appointment should have a location');
		Assert.areEqual(payloadModel.locationId, appointment.RawLocationId__c, 'The appointment should have the correct location id');
		Assert.areEqual(payloadModel.appointmentType, appointment.AppointmentType__c, 'The appointment should have the correct type');
		Assert.areEqual(payloadModel.appointmentStatus, appointment.Status__c, 'The appointment should have the correct status');
	}
}
