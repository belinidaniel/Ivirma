/**
 * @description  : Unit tests for the EmrServerAbstractDataProcessor class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
@isTest
private class EmrServerAbstractDataProcessorTest {
	@TestSetup
	static void makeData() {
		insert new EmrServer__c(
			Name = 'XPTO',
			ApiSchemaSpec__c = 'XPTO',
			NamedCredential__c = 'https://unit.xpto.test',
			TimeoutRequestPeriod__c = 50000,
			InboundRequestsRetentionPeriod__c = 10,
			OutboundRequestsRetentionPeriod__c = 15
		);
	}

	@isTest
	static void testSuccessfullExecutionWithOneRequest() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');
		Assert.isNotNull(emrServer, 'EmrServer instance should not be null');

		Test.startTest();
		TestImplEmrServerAbstractDataProcessor processor = new TestImplEmrServerAbstractDataProcessor();
		processor.add(emrServer, new EmrRestClient.RestModel());
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isTrue(results[0].isSuccess(), 'Result should be successful');
	}

	@isTest
	static void testSuccessfullExecutionWithMultipleRequests() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		Test.startTest();
		TestImplEmrServerAbstractDataProcessor processor = new TestImplEmrServerAbstractDataProcessor();
		processor.add(emrServer, new List<EmrRestClient.RestModel>{ new EmrRestClient.RestModel(), new EmrRestClient.RestModel() });
		processor.add(emrServer, new EmrRestClient.RestModel(), 'Additional Context');
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(3, results.size(), 'There should be three results');
		Assert.isTrue(results[0].isSuccess(), 'First result should be successful');
		Assert.isTrue(results[1].isSuccess(), 'Second result should be successful');
		Assert.isTrue(results[2].isSuccess(), 'Third result should be successful');
	}

	@isTest
	static void testEmptyRequestList() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		Test.startTest();
		TestImplEmrServerAbstractDataProcessor processor = new TestImplEmrServerAbstractDataProcessor();
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(0, results.size(), 'There should be no results');
	}

	@isTest
	static void testExceptionHandling() {
		EmrServer emrServer = EmrServer.getInstance('XPTO');

		Test.startTest();
		TestImplWithExceptionEmrServerAbstractDataProcessor processor = new TestImplWithExceptionEmrServerAbstractDataProcessor();
		processor.add(emrServer, new EmrRestClient.RestModel());
		List<EmrServerDataProcessRequestResult> results = processor.process();
		Test.stopTest();

		Assert.isNotNull(results, 'Results should not be null');
		Assert.areEqual(1, results.size(), 'There should be one result');
		Assert.isFalse(results[0].isSuccess(), 'Result should not be successful');
		Assert.isNotNull(results[0].getMessage(), 'Message should not be null');
		Assert.isTrue(results[0].getMessage().contains('Test exception'), 'Message should match');
	}

	// Testable implementation of the abstract class
	private class TestImplEmrServerAbstractDataProcessor extends EmrServerAbstractDataProcessor {
		public TestImplEmrServerAbstractDataProcessor() {
			super();
		}

		Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
			return new Map<Object, Object>();
		}

		void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		}
	}

	private class TestImplWithExceptionEmrServerAbstractDataProcessor extends EmrServerAbstractDataProcessor {
		public TestImplWithExceptionEmrServerAbstractDataProcessor() {
			super();
		}

		Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
			return new Map<Object, Object>();
		}

		void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
			throw new EmrServerDataProcessException('Test exception');
		}
	}
}
