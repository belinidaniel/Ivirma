/**
 * @description  : This class implements the locations client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisLocationsClientImpl extends EmrRestClient.ClientImpl implements EmrRestClient.ILocations {
	public ArtemisLocationsClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : This method retrieves a location by its ID.
	 * @param        : locationId - The ID of the location to retrieve.
	 * @return       : ArtemisLocationRestModel
	 * @throws       : EmrRestClientException - If the location ID is null or empty.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisLocationRestModel getLocation(String locationId) {
		if (String.isBlank(locationId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.getLocation: Location ID cannot be null or empty.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/location/' + locationId);
		callout.setResponseType(ArtemisLocationRestModel.class);

		return (ArtemisLocationRestModel) callout.execute();
	}

	/**
	 * @description  : This method retrieves a list of all locations.
	 * @return       : List<ArtemisLocationRestModel>
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public List<ArtemisLocationRestModel> getLocations() {
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/location/list');
		callout.setResponseType(List<ArtemisLocationRestModel>.class);

		return (List<ArtemisLocationRestModel>) callout.execute();
	}
}
