/**
 * @description  : Unit tests for the EmrServer class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
@isTest
private class EmrServerTest {
	@TestSetup
	public static void makeData() {
		insert new EmrServer__c(
			Name = 'XPTO EMR',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
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
	static void testInstantiationWithExistingServerId() {
		EmrServer emrServer = EmrServer.getInstance(getTestEmrServerRecord().Id);

		Assert.isNotNull(emrServer, 'EmrServer instance should not be null');
		Assert.areEqual('XPTO EMR', emrServer.name, 'Name should match');
		Assert.areEqual('XPTO', emrServer.apiSchemaSpec, 'API Schema Spec should match');
		Assert.areEqual('https://unit.xpto.test', emrServer.namedCredential, 'Named Credential should match');
		Assert.areEqual(10, emrServer.inboundRequestsRetentionPeriod, 'Inbound Retention Period should match');
		Assert.areEqual(15, emrServer.outboundRequestsRetentionPeriod, 'Outbound Retention Period should match');
		Assert.areEqual(50000, emrServer.timeoutRequestsAfter, 'Timeout Requests After should match');
	}

	@isTest
	static void testInstantiationWithoutExistingServerId() {
		EmrServer emrServer = EmrServer.getInstance('001000000000000001');
		Assert.isNull(emrServer, 'EmrServer instance should be null');
	}

	@isTest
	static void shouldTrackOutboundOperationRequest() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://unit.xpto.test');
		request.setMethod('POST');

		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setBody('{"status":"success"}');

		Test.startTest();
		EmrServer.getInstance(getTestEmrServerRecord().Id).trackOutboundRequest(request, response, 50000);
		Test.stopTest();

		List<EmrServerOutboundRequest__c> requests = [SELECT Id FROM EmrServerOutboundRequest__c];
		Assert.isTrue(requests.size() > 0, 'Request entry should heve been created');
	}

	@isTest
	static void shouldTrackInboundOperationRequest() {
		EmrServer__c emrServerRecord = getTestEmrServerRecord();

		Test.startTest();
		EmrServer.getInstance(emrServerRecord.Id).reportInboundRequest('Update', '0001', 'Account', '{ "message": "ok"}', 'OK', 'ok');
		Test.stopTest();

		List<EmrServerInboundRequest__c> requests = [SELECT Id FROM EmrServerInboundRequest__c];
		Assert.isTrue(requests.size() > 0, 'Request entries should heve been created');
	}
}
