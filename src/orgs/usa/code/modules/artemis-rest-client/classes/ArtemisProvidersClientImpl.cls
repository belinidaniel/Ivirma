/**
 * @description  : This class implements the providers client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisProvidersClientImpl extends EmrRestClient.ClientImpl implements EmrRestClient.IProviders {
	public ArtemisProvidersClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : This method retrieves a provider by its ID.
	 * @param        : providerId - The ID of the provider to retrieve.
	 * @return       : ArtemisProviderRestModel
	 * @throws       : EmrRestClientException - If the provider ID is null or empty.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisProviderRestModel getProvider(String providerId) {
		if (String.isBlank(providerId)) {
			throw new EmrRestClientException('ArtemisProvidersClientImpl.getProvider: Provider ID cannot be null or empty.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/provider/' + providerId);
		callout.setResponseType(ArtemisProviderRestModel.class);

		return (ArtemisProviderRestModel) callout.execute();
	}

	/**
	 * @description  : This method retrieves a list of all providers.
	 * @return       : List<ArtemisProviderRestModel>
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public List<ArtemisProviderRestModel> getProviders() {
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/provider/list');
		callout.setResponseType(List<ArtemisProviderRestModel>.class);

		return (List<ArtemisProviderRestModel>) callout.execute();
	}

	/**
	 * @description  : This method retrieves a provider based on the given parameters. Only NPI is supported.
	 * @param        : params - A map of search parameters. Currently, only 'npi' is supported.
	 * @return       : ArtemisProviderRestModel
	 * @throws       : EmrRestClientException - If the NPI parameter is missing.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisProviderRestModel findProvider(Map<String, Object> params) {
		if (params == null || params.isEmpty() || !params.containsKey('npi')) {
			throw new EmrRestClientException('ArtemisRestClientImpl.findProvider: NPI parameter is required.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/provider/findByNpi');
		callout.setParam('npi', (String) params.get('npi'), true);
		callout.setResponseType(ArtemisProviderRestModel.class);

		return (ArtemisProviderRestModel) callout.execute();
	}
}
