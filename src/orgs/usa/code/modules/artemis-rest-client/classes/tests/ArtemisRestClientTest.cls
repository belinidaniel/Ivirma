/**
 * @description  : Test class for the Artemis Rest Client implementation containing some utility methods to be reused in other test classes.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
@isTest
public class ArtemisRestClientTest {
	@TestSetup
	public static void makeData() {
		// Since we dont have a named credential for testing, lets hardcode an URL. It must contain at least the keyword "artemis"
		// in the domain to match the Http Callout Mocks created
		insert new EmrServer__c(Name = 'Artemis EMR', ApiSchemaSpec__c = 'Artemis', NamedCredential__c = 'https://unit.artemis.test');
	}

	@isTest
	private static void shouldInstantiateClient() {
		ArtemisRestClient client = getTestRestClientInstance();

		Assert.isNotNull(client, 'Client should have been instantiated');
	}

	@isTest
	private static void shouldThrowProperFormattedErrorException() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config().mock('invalid_endpoint', new InvalidEnpointArtemisMock()));

		ArtemisRestClient client = getTestRestClientInstance();
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/someEndpoint');

		Test.startTest();
		try {
			callout.execute();
			Assert.fail('Expected exception not thrown');
		} catch (ArtemisRestClientApiErrorException e) {
			Assert.isNotNull(e.getResponse(), 'Error response should not be null');
			Assert.isNotNull(e.getMessage(), 'Error message should not be null');
			Assert.areEqual('INVALID_ENDPOINT', e.response.error.code, 'Error code should be INVALID_ENDPOINT');
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	private static void shouldThrowProperFormattedErrorExceptionOnInvalidJsonResponse() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config().mock('invalid_endpoint', new InvalidEnpointWithInvalidJsonArtemisMock()));

		ArtemisRestClient client = getTestRestClientInstance();
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/someEndpoint');

		Test.startTest();
		try {
			callout.execute();
			Assert.fail('Expected exception not thrown');
		} catch (ArtemisRestClientApiErrorException e) {
			Assert.isNotNull(e.getResponse(), 'Error response should not be null');
			Assert.isNotNull(e.getMessage(), 'Error message should not be null');
			Assert.areEqual('RESPONSE_PARSE_ERROR', e.response.error.code, 'Error code should be RESPONSE_PARSE_ERROR');
		} catch (Exception e) {
			Assert.fail('Unexpected exception thrown: ' + e.getMessage());
		}
		Test.stopTest();
	}

	/**
	 * Helper methods
	 */

	public static ArtemisRestClient getTestRestClientInstance() {
		Id emrServerId = [SELECT Id FROM EmrServer__c WHERE Name = 'Artemis EMR' LIMIT 1].Id;

		return (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(emrServerId);
	}

	public class InvalidEnpointArtemisMock extends HttpCalloutMockRouter {
		public InvalidEnpointArtemisMock() {
			ArtemisErrorResponseRestModel errorResponse = new ArtemisErrorResponseRestModel('ERROR', 'INVALID_ENDPOINT', 'Invalid endpoint');

			mock('invalid_endpoint', 'GET', '.*artemis.*/api/v1/someEndpoint', HttpMocks.json(400, 'ERROR', errorResponse));
		}
	}

	public class InvalidEnpointWithInvalidJsonArtemisMock extends HttpCalloutMockRouter {
		public InvalidEnpointWithInvalidJsonArtemisMock() {
			mock('invalid_endpoint', 'GET', '.*artemis.*/api/v1/someEndpoint', HttpMocks.text(400, 'ERROR', '{ invalid: json }'));
		}
	}
}
