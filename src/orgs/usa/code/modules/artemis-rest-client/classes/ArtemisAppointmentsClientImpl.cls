/**
 * @description  : This class implements the appointments client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisAppointmentsClientImpl extends EmrRestClient.ClientImpl implements EmrRestClient.IAppointments {
	public ArtemisAppointmentsClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : Creates a new appointment
	 * @param        : appointment - The appointment to create
	 * @return       : ArtemisAppointmentRestModel - The created appointment
	 * @throws       : EmrRestClientException - If any required input parameter is invalid or missing
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error
	 **/
	public ArtemisAppointmentRestModel createAppointment(EmrRestClient.RestModel appointment) {
		if (appointment == null) {
			throw new EmrRestClientException('ArtemisRestClientImpl.createAppointment: Appointment cannot be null.');
		}

		ArtemisNewAppointmentRestModel newAppointment = (ArtemisNewAppointmentRestModel) appointment;

		if (String.isBlank(newAppointment.patientId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.createAppointment: Patient ID cannot be null or empty.');
		}
		if (String.isBlank(newAppointment.slotId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.createAppointment: Slot ID cannot be null or empty.');
		}

		if (newAppointment.waitingListPreferences != null) {
			//If ANY is in the list or the list has all possivel days of week selected or it's empty, set the list to just ANY
			if (
				newAppointment.waitingListPreferences.daysOfWeek == null ||
				newAppointment.waitingListPreferences.daysOfWeek.isEmpty() ||
				newAppointment.waitingListPreferences.daysOfWeek.indexOf('ANY') != -1 ||
				newAppointment.waitingListPreferences.daysOfWeek.size() > 7
			) {
				newAppointment.waitingListPreferences.daysOfWeek = new List<String>{ 'ANY' };
			}

			//If the time of day is empty, set it to ANY
			if (String.isBlank(newAppointment.waitingListPreferences.timeOfDay)) {
				newAppointment.waitingListPreferences.timeOfDay = 'ANY';
			}
		}

		Callout callout = client.buildCallout();
		callout.setMethod('POST');
		callout.setEndpoint('/api/v1/appointment');
		callout.setBody(newAppointment.serialize());
		callout.setResponseType(ArtemisAppointmentRestModel.class);

		return (ArtemisAppointmentRestModel) callout.execute();
	}

	/**
	 * @description  : Retrieves an appointment by its ID
	 * @param        : appointmentId - The ID of the appointment to retrieve
	 * @return       : ArtemisAppointmentRestModel - The retrieved appointment
	 * @throws       : EmrRestClientException - If the appointment ID is null or empty
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error
	 **/
	public ArtemisAppointmentRestModel getAppointment(String appointmentId) {
		if (String.isBlank(appointmentId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.getAppointment: Appointment ID cannot be null or empty.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/appointment/' + appointmentId);
		callout.setResponseType(ArtemisAppointmentRestModel.class);

		return (ArtemisAppointmentRestModel) callout.execute();
	}

	/**
	 * @description  : Cancels an appointment by its ID
	 * @param        : appointmentId - The ID of the appointment to cancel
	 * @param        : cancelRequestInfo - The cancellation request information
	 * @return       : EmrRestClient.RestModel - The response from the API - TODO
	 * @throws       : EmrRestClientException - IF any required input parameter is invalid or missing
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error
	 **/
	public EmrRestClient.RestModel cancelAppointment(String appointmentId, EmrRestClient.RestModel cancelRequestInfo) {
		if (String.isBlank(appointmentId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.cancelAppointment: Appointment ID cannot be null or empty.');
		}

		ArtemisCancelAppointmentRestModel cancelRequest = (ArtemisCancelAppointmentRestModel) cancelRequestInfo;
		if (cancelRequest == null) {
			throw new EmrRestClientException('ArtemisRestClientImpl.cancelAppointment: Cancel request info cannot be null.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('PUT');
		callout.setEndpoint('/api/v1/appointment/' + appointmentId + '/cancel');
		callout.setBody(cancelRequest.serialize());
		// callout.setResponseType(ArtemisAppointmentRestModel.class); //TODO define response model

		callout.execute(); //TODO define response model

		return new EmrRestClient.RestModel(); //TODO define response model
	}
}
