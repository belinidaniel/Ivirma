/**
 * @description  : This is a test implementation of the EmrRestClientFactory class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
@isTest
private class EmrRestClientFactoryTest {
	@TestSetup
	public static void makeData() {
		insert new EmrServer__c(
			Name = 'XPTO EMR',
			ApiSchemaSpec__c = 'EmrRestClientFactoryTest.TestSchemaSpec', //Schema defined in the bottom of this class
			NamedCredential__c = 'https://unit.xpto.test'
		);
	}

	private static EmrServer__c getTestEmrServerRecord() {
		return [
			SELECT Id, Name, ApiSchemaSpec__c, TimeoutRequestPeriod__c, InboundRequestsRetentionPeriod__c, OutboundRequestsRetentionPeriod__c
			FROM EmrServer__c
			LIMIT 1
		];
	}

	@isTest
	static void shouldFailToInstantiateNotImplementedSchema() {
		EmrServer__c emrServerRecord = getTestEmrServerRecord();
		emrServerRecord.ApiSchemaSpec__c = 'NotImplementedSchema';
		update emrServerRecord;

		Test.startTest();
		try {
			EmrRestClientFactory.getRestClientInstance(emrServerRecord.Id);
			Assert.fail('Expected EmrRestClientException but got none');
		} catch (EmrRestClientException ex) {
			Assert.isTrue(ex.getMessage().contains('Invalid API Schema Spec'), 'Expected exception error message to contain "Invalid API Schema Spec"');
		} catch (Exception ex) {
			Assert.fail('Expected EmrRestClientException but got: ' + ex.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shouldInstantiateImplementedSchema() {
		EmrServer__c emrServerRecord = getTestEmrServerRecord();

		Test.startTest();
		try {
			EmrRestClient testRestClientIntance = EmrRestClientFactory.getRestClientInstance(emrServerRecord.Id);
			Assert.isNotNull(testRestClientIntance, 'Expected testRestClientIntance to be not null');
		} catch (Exception ex) {
			Assert.fail('No expected exception but got: ' + ex.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void shoulAllowToBuildACalloutForClient() {
		Test.setMock(
			HttpCalloutMock.class,
			HttpMocks.config().mock('testEndpoint', 'GET', 'https://unit.xpto.test/api/v1/testEndpoint', HttpMocks.text(200, 'OK', '{"status":"OK"}'))
		);

		EmrServer__c emrServerRecord = getTestEmrServerRecord();

		Test.startTest();

		EmrRestClient testRestClientIntance = EmrRestClientFactory.getRestClientInstance(emrServerRecord.Id);
		Assert.isNotNull(testRestClientIntance, 'Expected testRestClientIntance to be not null');

		Callout simpleCallout = testRestClientIntance.buildCallout();
		Assert.isNotNull(simpleCallout, 'Expected callout to be not null');

		simpleCallout.setMethod('GET');
		simpleCallout.setEndpoint('/api/v1/testEndpoint');
		simpleCallout.setResponseType(TestReponseModel.class);

		TestReponseModel response = (TestReponseModel) simpleCallout.execute();
		Assert.isNotNull(response, 'Expected response to be not null');
		Assert.isTrue(response.status == 'OK', 'Expected response status to be OK');

		Test.stopTest();
	}

	/**
	 * @description  : This is a test implementation of the EmrRestClient class for testing purposes.
	 */
	public class TestSchemaSpecRestClient extends EmrRestClient {
	}

	public class TestReponseModel extends EmrRestClient.RestModel {
		public String status;
		public TestReponseModel(String status) {
			this.status = status;
		}
	}
}
