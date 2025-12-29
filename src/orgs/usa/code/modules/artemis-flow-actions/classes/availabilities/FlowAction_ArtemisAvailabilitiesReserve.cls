/**
 * @description  : Allows to reserve an availability in a given Artemis server from Flows
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
public with sharing class FlowAction_ArtemisAvailabilitiesReserve {
	/**
	 * @description  : Reserve an availability in a given Artemis server
	 * @param        : List<FlowAction_ArtemisAvailabilitiesReserveRequest> requests
	 */
	@InvocableMethod(
		label='Reserve an availability time slot in Artemis'
		description='Reserve an availability time slot in Artemis'
		category='Artemis REST Client'
		iconName='slds:standard:invocable_action'
	)
	public static List<FlowAction_ArtemisAvailabilitiesReserveResponse> reserveAvailability(List<FlowAction_ArtemisAvailabilitiesReserveRequest> requests) {
		List<FlowAction_ArtemisAvailabilitiesReserveResponse> reservationResults = new List<FlowAction_ArtemisAvailabilitiesReserveResponse>();
		for (FlowAction_ArtemisAvailabilitiesReserveRequest request : requests) {
			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(request.emrServerId);

			FlowAction_ArtemisAvailabilitiesReserveResponse requestResponse = new FlowAction_ArtemisAvailabilitiesReserveResponse();
			requestResponse.emrServerId = request.emrServerId;

			try {
				ArtemisAvailabilityRestModel response = restClient.availabilities.reserveAvailability(request.availabilitySlotId);
				requestResponse.isSuccess = true;
				requestResponse.reservedAvailabilitySlot = response;
			} catch (ArtemisRestClientApiErrorException e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
				requestResponse.errorResponse = e.getResponse();
			} catch (Exception e) {
				requestResponse.isSuccess = false;
				requestResponse.errorMessage = e.getMessage();
			}
			reservationResults.add(requestResponse);
		}
		return reservationResults;
	}

	public class FlowAction_ArtemisAvailabilitiesReserveRequest {
		@InvocableVariable(label='Artemis Server Id' description='Artemis Server Id' required=true)
		public String emrServerId;

		@InvocableVariable(label='Availability slot Id' description='Availability slot Id' required=true)
		public String availabilitySlotId;
	}

	public class FlowAction_ArtemisAvailabilitiesReserveResponse {
		@InvocableVariable(label='Reserved Availability Slot' description='Reserved availability slot data, only returned if the request is successful')
		public ArtemisAvailabilityRestModel reservedAvailabilitySlot;

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
