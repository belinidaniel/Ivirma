/**
 * @description  : This class is responsible for creating instances of EmrRestClient based on the provided EMR Server ID.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public class EmrRestClientFactory {
	/**
	 * @description Creates and returns an instance of EmrRestClient based on the provided EMR Server ID
	 * @param emrServerIdOrName The ID or Name of the EMR Server record to create a client for
	 * @return EmrRestClient A specific implementation of EmrRestClient based on the server's API schema
	 * @throws EmrRestClientException If an error occurs while creating the client
	 */
	public static EmrRestClient getRestClientInstance(String emrServerIdOrName) {
		Logger.info('EmrRestClientFactory.getClientInstance: Creating rest client for EMR Server ID/Name: ' + emrServerIdOrName);
		EmrServer emrServer = EmrServer.getInstance(emrServerIdOrName);
		if (emrServer == null) {
			Logger.error('EmrRestClientFactory.getClientInstance: EMR Server not found for ID/Name: ' + emrServerIdOrName);
			Logger.saveLog();
			throw new EmrRestClientException('EmrRestClientFactory.getClientInstance: EMR Server not found for ID/Name: ' + emrServerIdOrName);
		}

		String apiSchemaSpec = emrServer.apiSchemaSpec;
		String className = apiSchemaSpec + 'RestClient';
		Type restClientType = Type.forName(className);

		if (restClientType == null) {
			// Handle unknown API schema spec
			Logger.error('EmrRestClientFactory.getClientInstance: Unknown API Schema Spec: ' + apiSchemaSpec);
			Logger.saveLog();
			throw new EmrRestClientException('EmrRestClientFactory.getClientInstance: Invalid API Schema Spec: ' + apiSchemaSpec);
		}

		try {
			EmrRestClient restClient = (EmrRestClient) restClientType.newInstance();
			restClient.emrServer = emrServer;

			Logger.info('EmrRestClientFactory.getClientInstance: Created rest client of type: ' + restClientType.getName());
			return restClient;
		} catch (Exception ex) {
			Logger.error('EmrRestClientFactory.getClientInstance: Error instantiating rest client of type ' + restClientType.getName(), ex);
			throw new EmrRestClientException('EmrRestClientFactory.getClientInstance: Error instantiating client: ' + ex.getMessage());
		} finally {
			Logger.saveLog();
		}
	}
}
