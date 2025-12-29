/**
 * @description  : This class is responsible for processing Appointments data from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisAppointmentsDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisAppointmentsDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();

		// Get existing appointments
		Set<String> appointmentIds = Collection.of(payloads).collect(new AppointmentIdMapper()).getSetString();
		Map<String, Appointment__c> existingAppointmentsByServerAndKey = (Map<String, Appointment__c>) Collection.of(
				new AppointmentQuery().byEmrServerId(emrServerIds).byExternalId(appointmentIds).getList()
			)
			.mapByConcatenation(Appointment__c.EmrServer__c, Appointment__c.EmrAppointmentId__c);

		// Get existing locations
		Set<String> locationIds = Collection.of(payloads).collect(new AppointmentLocationIdMapper()).getSetString();
		locationIds.remove(null); // Remove null id values, if any.
		Map<String, Account> existingLocationsByServerAndKey = (Map<String, Account>) Collection.of(
				new LocationQuery().byEmrServerId(emrServerIds).byExternalId(locationIds).getList()
			)
			.mapByConcatenation(Account.LocationEmrServer__c, Account.LocationArtemisExternalId__c);

		// Get existing providers references
		Set<String> providerIds = Collection.of(payloads).collect(new AppointmentProviderIdMapper()).getSetString();
		providerIds.remove(null); // Remove null id values, if any.
		Map<String, EmrServerContactReference__c> ermProviderReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byIdentifier(providerIds).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Identifier__c);

		// Get existing patients references
		Set<String> patientIds = Collection.of(payloads).collect(new AppointmentPatientIdMapper()).getSetString();
		patientIds.remove(null); // Remove null id values, if any.
		Map<String, PatientServerProfile__c> existingPatientServerProfilesByServerAndKey = (Map<String, PatientServerProfile__c>) Collection.of(
				new PatientServerProfileQuery().byEmrServerId(emrServerIds).byExternalId(patientIds).getList()
			)
			.mapByConcatenation(PatientServerProfile__c.EmrServer__c, PatientServerProfile__c.ArtemisPatientId__c);

		AppointmentPreparedData result = new AppointmentPreparedData();
		result.existingAppointmentsByServerAndKey = existingAppointmentsByServerAndKey;
		result.existingLocationsByServerAndKey = existingLocationsByServerAndKey;
		result.ermProviderReferencesByServerAndKey = ermProviderReferencesByServerAndKey;
		result.existingPatientServerProfilesByServerAndKey = existingPatientServerProfilesByServerAndKey;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		AppointmentPreparedData preparedData = (AppointmentPreparedData) context.preparedData;
		ArtemisAppointmentRestModel appointmentPayload = (ArtemisAppointmentRestModel) payload;

		String sourceEmrServerId = context.sourceServer.emrServerId;
		String appointmentId = appointmentPayload.id;

		Appointment__c existingAppointmentRecord = preparedData.existingAppointmentsByServerAndKey.get(sourceEmrServerId + '' + appointmentId);

		ArtemisAppointmentRestModel.ToSObjectContextRefs contextRefs = new ArtemisAppointmentRestModel.ToSObjectContextRefs();
		contextRefs.sfLocationId = preparedData.existingLocationsByServerAndKey.get(sourceEmrServerId + '' + appointmentPayload.locationId)?.Id;
		contextRefs.sfPatientId = preparedData.existingPatientServerProfilesByServerAndKey.get(sourceEmrServerId + '' + appointmentPayload.patientId)
			?.PatientAccount__c;
		contextRefs.sfProviderId = preparedData.ermProviderReferencesByServerAndKey.get(sourceEmrServerId + '' + appointmentPayload.providerId)?.Contact__c;

		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();
		if (existingAppointmentRecord == null) {
			Appointment__c appointment = appointmentPayload.toSObject(contextRefs);
			appointment.EmrServer__c = sourceEmrServerId;
			databaseService.insertRecord(appointment);
		} else {
			Appointment__c appointment = appointmentPayload.toSObject(existingAppointmentRecord.Id, contextRefs);
			databaseService.updateRecord(appointment);
		}
	}

	private class AppointmentPreparedData {
		public Map<String, Appointment__c> existingAppointmentsByServerAndKey { get; set; }
		public Map<String, Account> existingLocationsByServerAndKey { get; set; }
		public Map<String, EmrServerContactReference__c> ermProviderReferencesByServerAndKey { get; set; }
		public Map<String, PatientServerProfile__c> existingPatientServerProfilesByServerAndKey { get; set; }
	}

	private class AppointmentIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisAppointmentRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class AppointmentLocationIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisAppointmentRestModel) item).locationId;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class AppointmentPatientIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisAppointmentRestModel) item).patientId;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class AppointmentProviderIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisAppointmentRestModel) item).providerId;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
