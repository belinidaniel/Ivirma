/**
 * @description  : Allows to create a new appointment in Artemis from Flows
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
public with sharing class FlowAction_ArtemisAppointmentsCreate {
	/**
	 * @description  : Creates a new appointment in Artemis
	 * @param        : List<FlowAction_ArtemisAppointmentsCreateRequest> requests
	 * @return       : List<FlowAction_ArtemisAppointmentsCreateResponse> A response for each request
	 */
	@InvocableMethod(
		label='Create an appointment in Artemis'
		description='Create an appointment in Artemis'
		category='Artemis REST Client'
		iconName='slds:standard:invocable_action'
	)
	public static List<FlowAction_ArtemisAppointmentsCreateResponse> createAppointment(List<FlowAction_ArtemisAppointmentsCreateRequest> requests) {
		List<FlowAction_ArtemisAppointmentsCreateResponse> appointmentResults = new List<FlowAction_ArtemisAppointmentsCreateResponse>();
		List<Appointment__c> appointmentsToCreate = new List<Appointment__c>();

		for (FlowAction_ArtemisAppointmentsCreateRequest request : requests) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(request.emrServerId);

			FlowAction_ArtemisAppointmentsCreateResponse requestResponse = new FlowAction_ArtemisAppointmentsCreateResponse();
			requestResponse.emrServerId = request.emrServerId;
			requestResponse.newAppointmentData = request.appointment;
			try {
				ArtemisAppointmentRestModel response = restClient.appointments.createAppointment(request.appointment);
				requestResponse.appointment = response;
				requestResponse.isSuccess = true;

				// we could create the appointment record directly here using its data processor, but to avoid the overhead of the data processor, we will create the appointment record just with the basic data.
				// and then we will force the update of the appointment record later via Platform Event - just as like as if the EMR Server created it
				requestResponse.appointmentRecord = new Appointment__c(
					Patient__c = request.patientAccountId,
					EmrAppointmentId__c = response.id,
					EmrServer__c = request.emrServerId,
					ScheduledBy__c = UserInfo.getUserId() //TODO: Artemis should provide the user reference instead...
				);
				appointmentsToCreate.add(requestResponse.appointmentRecord);
			} catch (ArtemisRestClientApiErrorException e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
				requestResponse.errorResponse = e.getResponse();
			} catch (Exception e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
			}
			appointmentResults.add(requestResponse);
		}

		if (!appointmentsToCreate.isEmpty()) {
			insert appointmentsToCreate;

			for (FlowAction_ArtemisAppointmentsCreateResponse response : appointmentResults) {
				response.appointmentId = response.appointmentRecord?.Id;

				// Force the update of the appointment record, as if it was created by the EMR Server
				EventBus.publish(
					new ArtemisChangeEvent__e(
						ArtemisServer__c = response.emrServerId,
						Event__c = 'create',
						ResourceIdentifier__c = response.appointment.id,
						ResourceName__c = 'appointment'
					)
				);
			}
		}

		return appointmentResults;
	}

	public class FlowAction_ArtemisAppointmentsCreateRequest {
		@InvocableVariable(label='Artemis Server Id' description='Artemis Server Id' required=true)
		public String emrServerId;

		@InvocableVariable(label='Appointment' description='Appointment data' required=true)
		public ArtemisNewAppointmentRestModel appointment;

		@InvocableVariable(label='Patient Account Id' description='Patient Account Id' required=true)
		public String patientAccountId;
	}

	public class FlowAction_ArtemisAppointmentsCreateResponse {
		@InvocableVariable(label='Appointment' description='Created appointment data, only returned if the request is successful')
		public ArtemisAppointmentRestModel appointment;

		@InvocableVariable(label='Appointment Id' description='Appointment Id')
		public Id appointmentId;

		@InvocableVariable(label='New Appointment data' description='New appointment data used for the appointment creation')
		public ArtemisNewAppointmentRestModel newAppointmentData;

		//Internal use only - will not be returned to the flow
		public Appointment__c appointmentRecord;

		@InvocableVariable(label='Artemis Server Id' description='Artemis Server Id' required=true)
		public String emrServerId;

		@InvocableVariable(label='Is Success' description='Is Success')
		public Boolean isSuccess;

		@InvocableVariable(label='Error Message' description='Error Message')
		public String errorMessage;

		@InvocableVariable(label='Error Response' description='In case of an error from the Artemis API, the error response will be returned')
		public ArtemisErrorResponseRestModel errorResponse;
	}
}
