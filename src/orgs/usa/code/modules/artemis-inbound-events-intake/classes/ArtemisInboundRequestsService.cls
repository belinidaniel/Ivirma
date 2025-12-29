/**
 * @description  : Service class for processing inbound requests and events from Artemis.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisEventsIntake
 **/
public class ArtemisInboundRequestsService {
	/**
	 * Processes a list of EmrServerInboundRequest__c requests. This will process the requests based on the resource type and update the status accordingly.
	 * @param requests The list of EmrServerInboundRequest__c requests to process.
	 */
	public static void processRequests(List<EmrServerInboundRequest__c> requests) {
		List<EmrServerInboundRequest__c> requestsToProcess = (List<EmrServerInboundRequest__c>) Collection.of(requests)
			.filter(EmrServerInboundRequest__c.Status__c)
			.equals('TO_PROCESS')
			.getList();

		if (requestsToProcess.isEmpty()) {
			Logger.info('No requests to process');
			Logger.saveLog();
			return;
		}

		Map<String, List<EmrServerInboundRequest__c>> requestsByResource = (Map<String, List<EmrServerInboundRequest__c>>) Collection.of(requestsToProcess)
			.groupBy(EmrServerInboundRequest__c.Resource__c);

		for (String resource : requestsByResource.keySet()) {
			List<EmrServerInboundRequest__c> resourceRequests = requestsByResource.get(resource);

			EmrServerAbstractDataProcessor dataProcessor;
			if (resource == 'appointment') {
				dataProcessor = new ArtemisAppointmentsDataProcessor();
				for (EmrServerInboundRequest__c request : resourceRequests) {
					ArtemisAppointmentRestModel payload = (ArtemisAppointmentRestModel) JSON.deserialize(request.Payload__c, ArtemisAppointmentRestModel.class);
					dataProcessor.add(EmrServer.getInstance(request.EmrServer__c), payload);
				}
			} else if (resource == 'patient') {
				dataProcessor = new ArtemisPatientsDataProcessor();
				for (EmrServerInboundRequest__c request : resourceRequests) {
					ArtemisPatientRestModel payload = (ArtemisPatientRestModel) JSON.deserialize(request.Payload__c, ArtemisPatientRestModel.class);
					dataProcessor.add(EmrServer.getInstance(request.EmrServer__c), payload);
				}
			} else if (resource == 'practitioner') {
				dataProcessor = new ArtemisPractitionersDataProcessor();
				for (EmrServerInboundRequest__c request : resourceRequests) {
					ArtemisPractitionerRestModel payload = (ArtemisPractitionerRestModel) JSON.deserialize(
						request.Payload__c,
						ArtemisPractitionerRestModel.class
					);
					dataProcessor.add(EmrServer.getInstance(request.EmrServer__c), payload);
				}
			} else if (resource == 'location') {
				dataProcessor = new ArtemisLocationsDataProcessor();
				for (EmrServerInboundRequest__c request : resourceRequests) {
					ArtemisLocationRestModel payload = (ArtemisLocationRestModel) JSON.deserialize(request.Payload__c, ArtemisLocationRestModel.class);
					dataProcessor.add(EmrServer.getInstance(request.EmrServer__c), payload);
				}
			} else if (resource == 'provider') {
				dataProcessor = new ArtemisProvidersDataProcessor();
				for (EmrServerInboundRequest__c request : resourceRequests) {
					ArtemisProviderRestModel payload = (ArtemisProviderRestModel) JSON.deserialize(request.Payload__c, ArtemisProviderRestModel.class);
					dataProcessor.add(EmrServer.getInstance(request.EmrServer__c), payload);
				}
			} else {
				//This else statement should never be reached because EmrServerInboundRequest__c TO_PROCESS records, are only created for the supported resources.
				Logger.error('Unexpected resource type when processing requests: ' + resource);
				Logger.saveLog();
			}

			// Process the data
			List<EmrServerDataProcessRequestResult> results = dataProcessor.process();

			//Process the results. They should be the same size and order as the requests.
			for (Integer i = 0; i < results.size(); i++) {
				EmrServerInboundRequest__c request = resourceRequests[i];
				EmrServerDataProcessRequestResult result = results[i];

				if (result.isSuccess()) {
					request.Status__c = 'PROCESSED';
					request.StatusMessage__c = 'Request processed successfully';
				} else {
					request.Status__c = 'ERROR';
					request.StatusMessage__c = result.getMessage();
				}
			}
		}
	}

	/**
	 * Processes a list of ArtemisChangeEvent__e events. This will fetch the resource information back from Artemis and create a EmrServerInboundRequest__c linked to the EMR server for further processing.
	 * @param artemisChangeEvents The list of ArtemisChangeEvent__e events to process.
	 */
	public static void processEvents(List<ArtemisChangeEvent__e> artemisChangeEvents) {
		Logger.info('Processing ArtemisChangeEvent__e events: ' + artemisChangeEvents.size());

		for (ArtemisChangeEvent__e artemisChangeEvent : artemisChangeEvents) {
			processEvent(artemisChangeEvent);
		}

		Logger.saveLog();
	}

	/**
	 * Processes a single ArtemisChangeEvent__e event. This will fetch the resource information back from Artemis and create a EmrServerInboundRequest__c linked to the EMR server for further processing.
	 * @param changeEvent The ArtemisChangeEvent__e event to process.
	 */
	private static void processEvent(ArtemisChangeEvent__e changeEvent) {
		ArtemisRestClient artemisRestClient = null;
		try {
			artemisRestClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(changeEvent.ArtemisServer__c);
		} catch (EmrRestClientException ex) {
			Logger.error('EmrRestClientException while getting ArtemisRestClient instance', ex);
			Logger.saveLog();
			return;
		}

		String payload = null;
		String status = null;
		String statusMessage = null;

		String event = changeEvent.Event__c.toLowerCase();
		if (String.isBlank(changeEvent.ResourceIdentifier__c)) {
			//Resource identifier is required for all events
			status = 'INVALID_RESOURCE_IDENTIFIER';
			statusMessage = 'Resource identifier not provided';
		} else if (!(new List<String>{ 'create', 'update', 'delete' }).contains(event)) {
			//Only create, update and delete events are supported
			status = 'UNSUPPORTED_EVENT';
			statusMessage = 'Unsupported event type: ' + event;
		} else if (event == 'create' || event == 'update') {
			try {
				switch on changeEvent.ResourceName__c.toLowerCase() {
					when 'patient' {
						ArtemisPatientRestModel patient = artemisRestClient.patients.getPatient(changeEvent.ResourceIdentifier__c);
						payload = patient.serialize();
						status = 'TO_PROCESS';
					}
					when 'location' {
						ArtemisLocationRestModel location = artemisRestClient.locations.getLocation(changeEvent.ResourceIdentifier__c);
						payload = location.serialize();
						status = 'TO_PROCESS';
					}
					when 'provider' {
						ArtemisProviderRestModel provider = artemisRestClient.providers.getProvider(changeEvent.ResourceIdentifier__c);
						payload = provider.serialize();
						status = 'TO_PROCESS';
					}
					when 'practitioner' {
						ArtemisPractitionerRestModel practitioner = artemisRestClient.practitioners.getPractitioner(changeEvent.ResourceIdentifier__c);
						payload = practitioner.serialize();
						status = 'TO_PROCESS';
					}
					when 'appointment' {
						ArtemisAppointmentRestModel appointment = artemisRestClient.appointments.getAppointment(changeEvent.ResourceIdentifier__c);
						payload = appointment.serialize();
						status = 'TO_PROCESS';
					}
					when else {
						Logger.error('Unknown resource type: ' + changeEvent.ResourceName__c);

						status = 'UNKNOWN_RESOURCE_TYPE';
						statusMessage = 'Unknown resource type: ' + changeEvent.ResourceName__c;
					}
				}
			} catch (ArtemisRestClientApiErrorException ex) {
				Logger.error('ArtemisRestClientApiErrorException while processing request thrown', ex);
				payload = JSON.serialize(ex.getResponse());
				status = 'ARTEMIS_API_ERROR';
				statusMessage = 'Artemis server returned an error. View Payload field for more details';
			} catch (CalloutResponseException ex) {
				Logger.error('CalloutResponseException while processing request thrown', ex);
				status = 'CALLOUT_EXCEPTION';
				statusMessage = 'CalloutResponseException while processing request thrown:\n' + ex.getMessage();
			} catch (Exception ex) {
				Logger.error('Exception while processing request thrown', ex);
				status = 'EXCEPTION';
				statusMessage = 'Exception while processing request thrown:\n' + ex.getMessage() + '\n\n' + ex.getStackTraceString();
			}
		} else if (event == 'delete') {
			status = 'NOT_IMPLEMENTED_EVENT_TYPE_DELETE';
			statusMessage = 'Delete events are not supported / implemented.';
		}

		artemisRestClient.emrServer.reportInboundRequest(
			changeEvent.Event__c,
			changeEvent.ResourceIdentifier__c,
			changeEvent.ResourceName__c,
			payload,
			status,
			statusMessage
		);
	}
}
