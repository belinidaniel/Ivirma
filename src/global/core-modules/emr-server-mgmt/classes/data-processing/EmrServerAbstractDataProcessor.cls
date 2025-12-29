/**
 * @description  : Abstract class for processing data from EMR servers.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public abstract class EmrServerAbstractDataProcessor {
	private List<EmrServerDataProcessRequest> requests { get; set; }

	/**
	 * @description  : Constructor for the EmrServerAbstractDataProcessor class.
	 */
	public EmrServerAbstractDataProcessor() {
		this.requests = new List<EmrServerDataProcessRequest>();
	}

	/**
	 * @description  : Adds a list of payloads to the processor.
	 * @param sourceServer : The EMR server from which the payloads are coming from.
	 * @param payloads : List of payloads to be processed.
	 * @return : The current instance of the processor.
	 */
	public EmrServerAbstractDataProcessor add(EmrServer sourceServer, List<EmrRestClient.RestModel> payloads) {
		for (EmrRestClient.RestModel payload : payloads) {
			add(sourceServer, payload);
		}
		return this;
	}

	/**
	 * @description  : Adds a single payload to the processor.
	 * @param sourceServer : The EMR server from which the payload is coming from.
	 * @param payload : The payload to be processed.
	 * @return : The current instance of the processor.
	 */
	public EmrServerAbstractDataProcessor add(EmrServer sourceServer, EmrRestClient.RestModel payload) {
		return add(new EmrServerDataProcessRequest(sourceServer, payload));
	}

	/**
	 * @description  : Adds a single payload to the processor with additional context.
	 * @param sourceServer : The EMR server from which the payload is coming from.
	 * @param payload : The payload to be processed.
	 * @param additionalContext : Additional context for the request. This will be passed to the handle method within the context parameter.
	 * @return : The current instance of the processor.
	 */
	public EmrServerAbstractDataProcessor add(EmrServer sourceServer, EmrRestClient.RestModel payload, Object additionalContext) {
		return add(new EmrServerDataProcessRequest(sourceServer, payload, additionalContext));
	}

	/**
	 * @description  : Adds a single request to the processor.
	 * @param request : The request to be processed.
	 * @return : The current instance of the processor.
	 */
	public EmrServerAbstractDataProcessor add(EmrServerDataProcessRequest request) {
		return add(new List<EmrServerDataProcessRequest>{ request });
	}

	/**
	 * @description  : Adds a list of requests to the processor.
	 * @param requests : The requests to be processed.
	 * @return : The current instance of the processor.
	 */
	public EmrServerAbstractDataProcessor add(List<EmrServerDataProcessRequest> requests) {
		this.requests.addAll(requests);
		return this;
	}

	/**
	 * @description  : Processes the requests. This is where the actual data processing is done.
	 * @return : List of results for each request processed, in the same order as the requests were added.
	 */
	public List<EmrServerDataProcessRequestResult> process() {
		if (this.requests.isEmpty()) {
			return new List<EmrServerDataProcessRequestResult>();
		}

		// Group the payloads by server
		Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer = new Map<EmrServer, List<EmrRestClient.RestModel>>();
		List<EmrServer> servers = new List<EmrServer>();
		List<EmrRestClient.RestModel> payloads = new List<EmrRestClient.RestModel>();
		for (EmrServerDataProcessRequest request : this.requests) {
			if (!payloadsByServer.containsKey(request.sourceServer)) {
				payloadsByServer.put(request.sourceServer, new List<EmrRestClient.RestModel>());
				servers.add(request.sourceServer);
			}
			payloadsByServer.get(request.sourceServer).add(request.payload);
			payloads.add(request.payload);
		}

		// Prepare/warmup the data - this is where all initial data fetching should be done.
		Object preparedData = prepare(payloadsByServer, servers, payloads);

		List<EmrServerDataProcessRequestResult> results = new List<EmrServerDataProcessRequestResult>();
		for (EmrServerDataProcessRequest request : this.requests) {
			EmrServerDataProcessRequestResult result;
			try {
				EmrServerDataProcessRequestContext context = new EmrServerDataProcessRequestContext(
					request.sourceServer,
					preparedData,
					request.additionalContext
				);
				handle(request.payload, context);
				result = new EmrServerDataProcessRequestResult(true, 'Request processed successfully', request);
			} catch (Exception ex) {
				// Catch all exceptions. Will be added to the result.
				result = new EmrServerDataProcessRequestResult(
					false,
					'Error processing request: ' + ex.getMessage() + '\n\n' + ex.getStackTraceString(),
					request
				);
			} finally {
				Logger.saveLog();
			}
			results.add(result);
		}
		return results;
	}

	/**
	 * @description  : Prepares the data for processing. This is where all initial data fetching should be done.
	 * @param payloadsByServer : Map of EMR servers and their corresponding payloads.
	 * @param servers : Flattened list of EMR servers.
	 * @param payloads : Flattened list of payloads.
	 * @return : Any type of object holding the prepared data for processing. This will be provided to the handle method within the context parameter.
	 */
	abstract Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads);

	/**
	 * @description  : Handles the processing of each payload. This is where the actual data processing should be done. In case of errors, the handle method should throw an exception of type EmrServerDataProcessException.
	 * @param payload : The payload to be processed.
	 * @param context : The context for the request, including the source server and any prepared data.
	 */
	abstract void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context);

	public class EmrServerIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((EmrServer) item).emrServerId;
		}

		public Type valueType() {
			return Id.class;
		}
	}
}
