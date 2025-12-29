/**
 * @description  : This class is responsible for managing EMR server configurations and logging operations. Serves as a wrapper for the ErmServer__c settings record.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public class EmrServer {
	private static final Integer DEFAULT_TIMEOUT = 60000; // Default timeout of 60 seconds
	private static final Integer MAX_TIMEOUT = 120000; // Maximum timeout of 120 seconds

	public Id emrServerId { get; private set; }
	public String name { get; private set; }
	public String namedCredential { get; private set; }
	public String apiSchemaSpec { get; private set; }
	public Integer inboundRequestsRetentionPeriod { get; private set; }
	public Integer outboundRequestsRetentionPeriod { get; private set; }
	public Integer timeoutRequestsAfter { get; private set; } // in milliseconds
	public EmrServer__c emrServerRecord { get; private set; }

	@TestVisible
	private static final Map<String, EmrServer__c> EMR_SERVERS_MAP = new Map<String, EmrServer__c>();
	static {
		// Initialize the EMR_SERVERS_MAP with all EmrServer__c records
		for (EmrServer__c emrServer : (List<EmrServer__c>) new EmrServerQuery().getList()) {
			EMR_SERVERS_MAP.put(emrServer.Id, emrServer);
			EMR_SERVERS_MAP.put(emrServer.Name, emrServer);
		}
	}

	/**
	 * @description: Private constructor for EmrServer class. To instantiate a new EmrServer object, use the static method getInstance.
	 * @param emrServer: The EmrServer__c record used to initialize the EmrServer instance.
	 */
	private EmrServer(EmrServer__c emrServer) {
		this.emrServerRecord = emrServer;
		this.emrServerId = emrServer.Id;
		this.namedCredential = emrServer.NamedCredential__c;
		this.name = emrServer.Name;
		this.inboundRequestsRetentionPeriod = Math.max(0, Integer.valueOf(emrServer.InboundRequestsRetentionPeriod__c));
		this.outboundRequestsRetentionPeriod = Math.max(0, Integer.valueOf(emrServer.OutboundRequestsRetentionPeriod__c));
		this.timeoutRequestsAfter = Math.min(
			emrServer.TimeoutRequestPeriod__c != null ? Integer.valueOf(emrServer.TimeoutRequestPeriod__c) : DEFAULT_TIMEOUT,
			MAX_TIMEOUT
		);
		this.apiSchemaSpec = emrServer.APISchemaSpec__c;
	}

	/**
	 * @description: Retrieves an instance of EmrServer based on the provided Id.
	 * @param emrServerIdOrName: The Id or Name of the EmrServer__c record.
	 * @return: An instance of EmrServer or null if the record is not found.
	 */
	public static EmrServer getInstance(String emrServerIdOrName) {
		EmrServer__c emrServerRecord = EMR_SERVERS_MAP.get(emrServerIdOrName);
		return emrServerRecord == null ? null : new EmrServer(emrServerRecord);
	}

	/**
	 * @description: Tracks an outbound operation to the EMR server. This method is used to log the details of an outbound operation, including the request and response objects.
	 * @param request: The HttpRequest object representing the outbound operation.
	 * @param response: The HttpResponse object representing the response received from the outbound operation.
	 * @param duration: The duration of the outbound operation in milliseconds.
	 */
	public void trackOutboundRequest(HttpRequest request, HttpResponse response, Long duration) {
		Logger.info('Tracking EMR outbound operation ' + this.emrServerId);

		EmrServerOutboundRequestEvent__e requestEvent = new EmrServerOutboundRequestEvent__e(
			EmrServerId__c = this.emrServerId,
			Endpoint__c = request.getEndpoint()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.Endpoint__c.getDescribe().getLength()),
			Method__c = request.getMethod()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.Method__c.getDescribe().getLength()),
			RequestPayload__c = request.getBody()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.RequestPayload__c.getDescribe().getLength()),
			ResponsePayload__c = response?.getBody()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.ResponsePayload__c.getDescribe().getLength()),
			StatusCode__c = String.valueOf(response?.getStatusCode()),
			StatusMessage__c = response?.getStatus()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.StatusMessage__c.getDescribe().getLength()),
			RequestDuration__c = duration
		);

		publishEvent(requestEvent);

		Logger.saveLog();
	}

	/**
	 * @description: Tracks an outbound operation to the EMR server. This method is used to log the details of an outbound operation whenever the response is not available.
	 * @param request: The HttpRequest object representing the outbound operation.
	 * @param statusCode: The status code of the response received from the outbound operation.
	 * @param statusMessage: The status message of the response received from the outbound operation.
	 */
	public void trackOutboundRequest(HttpRequest request, String statusCode, String statusMessage) {
		Logger.info('Tracking EMR outbound operation ' + this.emrServerId);

		EmrServerOutboundRequestEvent__e requestEvent = new EmrServerOutboundRequestEvent__e(
			EmrServerId__c = this.emrServerId,
			Endpoint__c = request.getEndpoint()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.Endpoint__c.getDescribe().getLength()),
			Method__c = request.getMethod()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.Method__c.getDescribe().getLength()),
			RequestPayload__c = request.getBody()?.left(Schema.EmrServerOutboundRequestEvent__e.fields.RequestPayload__c.getDescribe().getLength()),
			StatusCode__c = statusCode,
			StatusMessage__c = statusMessage
		);

		publishEvent(requestEvent);

		Logger.saveLog();
	}

	/**
	 * @description: Tracks an inbound operation to the EMR server. This method is used to log the details of an inbound operation, including the event, identifier, and resource.
	 * @param event: The event of the inbound operation.
	 * @param identifier: The identifier of the inbound operation.
	 * @param resource: The resource of the inbound operation.
	 * @param payload: The payload of the inbound operation.
	 * @param status: The status of the inbound operation.
	 * @param statusMessage: The status message of the inbound operation.
	 */
	public void reportInboundRequest(String event, String identifier, String resource, String payload, String status, String statusMessage) {
		Logger.info('Tracking EMR inbound operation ' + this.emrServerId);

		EmrServerInboundRequestEvent__e requestEvent = new EmrServerInboundRequestEvent__e(
			EmrServerId__c = this.emrServerId,
			Event__c = event?.toLowerCase(),
			Identifier__c = identifier,
			Resource__c = resource?.toLowerCase(),
			Payload__c = payload,
			Status__c = status?.left(Schema.EmrServerInboundRequestEvent__e.fields.Status__c.getDescribe().getLength()),
			StatusMessage__c = statusMessage?.left(Schema.EmrServerInboundRequestEvent__e.fields.StatusMessage__c.getDescribe().getLength())
		);

		publishEvent(requestEvent);

		Logger.saveLog();
	}

	/**
	 * @description: Publishes a platform event.
	 * @param event: The event to be published.
	 */
	private void publishEvent(SObject event) {
		String eventSObjectName = event.getSObjectType().getDescribe().getName();
		try {
			EventBus.publish(event);
			Logger.info('Published platform event ' + eventSObjectName + ' successfully');
		} catch (Exception ex) {
			Logger.error('Error publishing platform event ' + eventSObjectName, ex);
		}
	}
}
