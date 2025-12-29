/**
 * @description  : Allows to get a patient from Artemis from Flows
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
public with sharing class FlowAction_ArtemisPatientsGet {
	@InvocableMethod(
		label='Get a patient from Artemis'
		description='Get a patient from Artemis'
		category='Artemis REST Client'
		iconName='slds:standard:invocable_action'
	)
	public static List<FlowAction_ArtemisPatientsGetResponse> getPatient(List<FlowAction_ArtemisPatientsGetRequest> requests) {
		List<FlowAction_ArtemisPatientsGetResponse> patientResults = new List<FlowAction_ArtemisPatientsGetResponse>();

		for (FlowAction_ArtemisPatientsGetRequest request : requests) {
			FlowAction_ArtemisPatientsGetResponse requestResponse = new FlowAction_ArtemisPatientsGetResponse();
			requestResponse.emrServerId = request.emrServerId;

			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(request.emrServerId);
			try {
				requestResponse.patientData = (ArtemisPatientRestModel) restClient.patients.getPatient(request.patientId);
				requestResponse.patientDataStringified = requestResponse.patientData.serialize();
				requestResponse.isSuccess = true;
			} catch (ArtemisRestClientApiErrorException e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
				requestResponse.errorResponse = e.getResponse();
			} catch (Exception e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
			}

			patientResults.add(requestResponse);
		}

		return patientResults;
	}

	public class FlowAction_ArtemisPatientsGetRequest {
		@InvocableVariable(label='EMR Server ID' required=true)
		public String emrServerId;

		@InvocableVariable(label='Patient ID' required=true)
		public String patientId;
	}

	public class FlowAction_ArtemisPatientsGetResponse {
		@InvocableVariable(label='Patient data')
		public ArtemisPatientRestModel patientData;

		@InvocableVariable(label='Patient data stringified')
		public String patientDataStringified;

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
