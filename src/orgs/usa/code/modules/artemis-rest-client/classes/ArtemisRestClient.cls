/**
 * @description  : This class exposes namespaces for the different rest client implementations
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisRestClient extends EmrRestClient {
	public ArtemisPatientsClientImpl patients { get; private set; }
	public ArtemisProvidersClientImpl providers { get; private set; }
	public ArtemisPractitionersClientImpl practitioners { get; private set; }
	public ArtemisLocationsClientImpl locations { get; private set; }
	public ArtemisAppointmentsClientImpl appointments { get; private set; }
	public ArtemisAvailabilitiesClientImpl availabilities { get; private set; }
	public ArtemisMetadataClientImpl metadata { get; private set; }

	public ArtemisRestClient() {
		super();
		this.patients = new ArtemisPatientsClientImpl(this);
		this.providers = new ArtemisProvidersClientImpl(this);
		this.practitioners = new ArtemisPractitionersClientImpl(this);
		this.locations = new ArtemisLocationsClientImpl(this);
		this.appointments = new ArtemisAppointmentsClientImpl(this);
		this.availabilities = new ArtemisAvailabilitiesClientImpl(this);
		this.metadata = new ArtemisMetadataClientImpl(this);
	}

	protected override void onAfterCalloutBuilt(Callout callout) {
		// override the default implementation of the errorCodeThrow handler defined in the superclass
		callout.onAfterCallout().replace('errorCodeThrow', new CustomArtemisErrorResponseHandler());
	}

	/*
	 * @description  : Handler to override the default implementation of the errorCodeThrow handler defined on the Callout request being built in the buildCallout method by the EmrRestClient class.
	 */
	private class CustomArtemisErrorResponseHandler implements Callout.Handler {
		public Object handle(Callout c) {
			Logger.info('ArtemisRestClient.CustomArtemisErrorResponseHandler: Handling error response from Artemis');

			// Parse the error response from Artemis and throw a custom exception with that response
			ArtemisErrorResponseRestModel errorResponse = null;
			try {
				errorResponse = (ArtemisErrorResponseRestModel) JSON.deserialize(c.getResponse()?.getBody(), ArtemisErrorResponseRestModel.class);
			} catch (JSONException ex) {
				Logger.error('ArtemisRestClient.CustomArtemisErrorResponseHandler: Error parsing Artemis error response', ex);
				Logger.error('ArtemisRestClient.CustomArtemisErrorResponseHandler')
					.setHttpRequestDetails(c.getRequest())
					.setHttpResponseDetails(c.getResponse());

				errorResponse = new ArtemisErrorResponseRestModel(
					'JSONException',
					'RESPONSE_PARSE_ERROR',
					'An error occurred while processing the error response from Artemis: ' + ex.getMessage()
				);
			}

			Logger.saveLog();

			throw new ArtemisRestClientApiErrorException(errorResponse);
		}
	}
}
