/**
 * @description  : This class is responsible for making REST API calls to the EMR server. Must be extended for actual implementation using Interfaces - cannot be constructed.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public abstract class EmrRestClient {
	public EmrServer emrServer { get; set; }

	public EmrRestClient() {
		// Default constructor
	}

	public EmrRestClient(EmrServer emrServer) {
		this.emrServer = emrServer;
	}

	/*
	 * @description  : This method is used to create a new instance of the Callout class for making REST API calls to the EMR server.
	 * @return       : Callout - A new instance of the Callout class for making REST API calls.
	 */
	public Callout buildCallout() {
		if (emrServer == null) {
			Logger.error('EmrRestClient.buildCallout: emrServer instance cannot be null.');
			Logger.saveLog();
			throw new EmrRestClientException('EmrRestClient: emrServer instance cannot be null.');
		}

		Callout callout = new ErmServerApiCallout(emrServer);
		callout.setTimeout(emrServer.timeoutRequestsAfter); //set default timeout

		onAfterCalloutBuilt(callout);

		return callout;
	}

	/*
	 * @description  : This method is used to set up the callout handlers for the EMR server. It is called by the buildCallout method.
	 * @param        : Callout - The callout instance to set up the handlers for.
	 */
	protected virtual void onAfterCalloutBuilt(Callout callout) {
		// Default implementation does nothing. Subclasses can override this method to add custom behavior.
	}

	private class ErmServerApiCallout extends Callout {
		private EmrServer emrServer { get; set; }

		ErmServerApiCallout(EmrServer emrServer) {
			this.emrServer = emrServer;
		}

		protected override void setupHandlers() {
			Logger.info('EmrRestClient.setupHandlers: Setting up callout handlers for EMR server: ' + emrServer.name);

			onBeforeCallout().add(new MissingNamedCredentialMatcher(), new NamedCredentialEndpointInjectorHandler(emrServer.namedCredential));

			onAfterCallout()
				.add('timeoutRetry', match.onTimeout(), action.retry(1)) // retry just once on timeout
				.add('logCalloutOperation', match.always(), new TrackEmrOutboundOperationHandler(emrServer)) // track the outbound operation in the EMR server record history
				.slot('beforeValidation')
				.add('exceptionLogging', match.onException(), new LogHandler(LoggingLevel.ERROR)) // debug error log in case of exception
				.add('exceptionLoggingThrow', match.onException(), action.throwEx()) // throw the exception in case of exception
				.add('errorCodeLogging', match.onAnyErrorCode(), new LogHandler(LoggingLevel.ERROR)) // debug error log in case of any error code > 300
				.add('errorCodeThrow', match.onAnyErrorCode(), action.throwEx()) // throw the exception in case of any error code > 300
				.add('successLogging', match.onSuccess(), new LogHandler(LoggingLevel.INFO)) // debug log in case of success
				.add('returnJSON', match.onSuccess(), action.returnJSON(responseType));

			Logger.info('EmrRestClient.setupHandlers: Callout handlers setup completed for EMR server: ' + emrServer.name);
			Logger.saveLog();
		}
	}

	private class MissingNamedCredentialMatcher implements Condition {
		public Boolean isTrue(Object item) {
			Callout c = (Callout) item;

			return c.getRequest().getEndpoint().indexOf('callout:') == -1;
		}
	}

	private class NamedCredentialEndpointInjectorHandler implements Callout.Handler {
		private String namedCredential { get; set; }
		public NamedCredentialEndpointInjectorHandler(String namedCredential) {
			this.namedCredential = namedCredential;
		}
		public Object handle(Callout c) {
			// This method injects the "callout:" prefix to the current endpoint URL to use the named credential defined in the EmrServer record.
			// During the test context, we set the namedCredential with the domain of the endpoint to be used in the test context, to properly mock the callout.

			String fullEndpoint = (Test.isRunningTest() ? '' : 'callout:') + this.namedCredential + c.getRequest().getEndpoint();
			c.getRequest().setEndpoint(fullEndpoint);
			return null;
		}
	}

	private class TrackEmrOutboundOperationHandler implements Callout.Handler {
		public EmrServer emrServer { get; set; }
		public TrackEmrOutboundOperationHandler(EmrServer emrServer) {
			this.emrServer = emrServer;
		}
		public Object handle(Callout c) {
			if (c.getCalloutException() != null) {
				this.emrServer.trackOutboundRequest(c.getRequest(), 'EXCEPTION', c.getCalloutException().getMessage());
			} else {
				this.emrServer.trackOutboundRequest(c.getRequest(), c.getResponse(), (Long) c.getMetadata('duration'));
			}

			return null;
		}
	}

	private class LogHandler implements Callout.Handler {
		private LoggingLevel level;
		LogHandler(LoggingLevel level) {
			this.level = level;
		}
		public Object handle(Callout c) {
			if (c.getCalloutException() != null) {
				Logger.error(c.getCalloutException().getMessage()).setHttpRequestDetails(c.getRequest()).setHttpResponseDetails(c.getResponse());
			} else {
				switch on this.level {
					when DEBUG {
						Logger.debug('').setHttpRequestDetails(c.getRequest()).setHttpResponseDetails(c.getResponse());
					}
					when INFO {
						Logger.info('').setHttpRequestDetails(c.getRequest()).setHttpResponseDetails(c.getResponse());
					}
					when WARN {
						Logger.warn('').setHttpRequestDetails(c.getRequest()).setHttpResponseDetails(c.getResponse());
					}
					when ERROR {
						Logger.error('').setHttpRequestDetails(c.getRequest()).setHttpResponseDetails(c.getResponse());
					}
				}
			}

			Logger.saveLog();
			return null;
		}
	}

	/**
	 * @description  : Generic class for EMR REST API models. Must be extended by all EMR REST API models.
	 **/
	public virtual class RestModel {
		@AuraEnabled
		public Map<String, Object> internalContext {
			get {
				if (this.internalContext == null) {
					this.internalContext = new Map<String, Object>();
				}
				return (Map<String, Object>) this.internalContext;
			}
			set {
				this.internalContext = value;
			}
		}

		public RestModel() {
			// Default constructor
		}

		/**
		 * @description  : Returns a safe boolean value - Makes sure the output is never null.
		 * @param        : input - The boolean value to check.
		 * @return       : Boolean - The safe boolean value.
		 */
		public Boolean getSafeBoolean(Boolean input) {
			return getSafeBoolean(input, false);
		}

		/**
		 * @description  : Returns a safe boolean value - Makes sure the output is never null.
		 * @param        : input - The boolean value to check.
		 * @param        : defaultValueWhenNull - The default value to return if the input is null.
		 * @return       : Boolean - The safe boolean value.
		 */
		public Boolean getSafeBoolean(Boolean input, Boolean defaultValueWhenNull) {
			return input == null ? defaultValueWhenNull : input;
		}

		/**
		 * @description  : Serializes this instance, suppressing the serialization of null values.
		 * @return       : String - The serialized JSON string of this instance.
		 */
		public String serialize() {
			return serialize(true);
		}

		/**
		 * @description  : Serializes this instance.
		 * @param        : suppressApexObjectNulls - Whether to suppress the serialization of null values.
		 * @return       : String - The serialized JSON string of this instance.
		 */
		public String serialize(Boolean suppressApexObjectNulls) {
			Map<String, Object> internalContextCopy = this.internalContext;
			this.internalContext = null;

			String stringified = JSON.serialize(this, suppressApexObjectNulls);
			this.internalContext = internalContextCopy;

			return stringified;
		}
	}

	/**
	 * @description  : Generic class for EMR REST API clients. Must be extended by all EMR REST API clients.
	 */
	public abstract class ClientImpl {
		protected EmrRestClient client { get; set; }
		public ClientImpl() {
			// Default constructor
		}
		public ClientImpl(EmrRestClient client) {
			this.client = client;
		}
	}

	/**
	 * @description  : Generic interface for EMR REST API clients for the Patients namespace. To be implemented by all EMR REST API clients.
	 */
	public interface IPatients {
		RestModel getPatient(String patientId);
		RestModel createPatient(RestModel patient);
		RestModel updatePatient(RestModel patient);
		RestModel findPatient(Map<String, Object> params);
	}

	/**
	 * @description  : Generic interface for EMR REST API clients for the Providers namespace. To be implemented by all EMR REST API clients.
	 */
	public interface IProviders {
		RestModel getProvider(String providerId);
		List<RestModel> getProviders();
		RestModel findProvider(Map<String, Object> params);
	}

	/**
	 * @description  : Generic interface for EMR REST API clients for the Locations namespace. To be implemented by all EMR REST API clients.
	 */
	public interface ILocations {
		RestModel getLocation(String locationId);
		List<RestModel> getLocations();
	}

	/**
	 * @description  : Generic interface for EMR REST API clients for the Appointments namespace. To be implemented by all EMR REST API clients.
	 */
	public interface IAppointments {
		RestModel createAppointment(RestModel appointment);
		RestModel getAppointment(String appointmentId);
		RestModel cancelAppointment(String appointmentId, RestModel cancelRequestInfo);
	}

	/**
	 * @description  : Generic interface for EMR REST API clients for the Availabilities namespace. To be implemented by all EMR REST API clients.
	 */
	public interface IAvailabilities {
		RestModel getAvailability(String availabilityId);
		RestModel reserveAvailability(String availabilityId);
		RestModel releaseAvailability(String availabilityId);
		List<RestModel> searchAvailabilities(Map<String, Object> filters);
	}
}
