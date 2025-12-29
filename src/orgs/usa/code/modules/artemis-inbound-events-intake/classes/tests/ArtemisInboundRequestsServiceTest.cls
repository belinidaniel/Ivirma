/**
 * @description  : Unit tests for the ArtemisInboundRequestsService class.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisEventsIntake
 **/
@isTest
private class ArtemisInboundRequestsServiceTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void shouldProcessEventAndRequest_MultipleEvents() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisChangeEvent__e patientEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'create',
			ResourceName__c = 'patient',
			ResourceIdentifier__c = '1001'
		);

		ArtemisChangeEvent__e locationEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'update',
			ResourceName__c = 'location',
			ResourceIdentifier__c = '1002'
		);

		ArtemisChangeEvent__e providerEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'update',
			ResourceName__c = 'provider',
			ResourceIdentifier__c = '1003'
		);

		ArtemisChangeEvent__e practitionerEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'update',
			ResourceName__c = 'practitioner',
			ResourceIdentifier__c = '1004'
		);

		ArtemisChangeEvent__e appointmentEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'update',
			ResourceName__c = 'appointment',
			ResourceIdentifier__c = '1005'
		);

		Test.startTest();
		ArtemisInboundRequestsService.processEvents(
			new List<ArtemisChangeEvent__e>{ patientEvent, locationEvent, providerEvent, practitionerEvent, appointmentEvent }
		);
		Test.stopTest();

		Assert.areEqual(5, [SELECT COUNT() FROM EmrServerInboundRequest__c], 'There should be five inbound requests logged');
	}

	@isTest
	static void shouldNotProcessUnknownResourceType() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisChangeEvent__e unknownEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'create',
			ResourceName__c = 'unknown_type',
			ResourceIdentifier__c = '1001'
		);

		Test.startTest();
		ArtemisInboundRequestsService.processEvents(new List<ArtemisChangeEvent__e>{ unknownEvent });
		Test.stopTest();

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerInboundRequest__c], 'There should be no inbound requests logged');

		EmrServerInboundRequest__c inboundRequest = [SELECT Id, Status__c, StatusMessage__c FROM EmrServerInboundRequest__c LIMIT 1];
		Assert.areEqual('UNKNOWN_RESOURCE_TYPE', inboundRequest.Status__c, 'The inbound request should have status UNKNOWN_RESOURCE_TYPE');
	}

	@isTest
	static void shouldNotProcessUnsupportedEventType() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisChangeEvent__e unsupportedEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'unknown_event_type',
			ResourceName__c = 'patient',
			ResourceIdentifier__c = '1001'
		);

		Test.startTest();
		ArtemisInboundRequestsService.processEvents(new List<ArtemisChangeEvent__e>{ unsupportedEvent });
		Test.stopTest();

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerInboundRequest__c], 'There should be no inbound requests logged');

		EmrServerInboundRequest__c inboundRequest = [SELECT Id, Status__c, StatusMessage__c FROM EmrServerInboundRequest__c LIMIT 1];
		Assert.areEqual('UNSUPPORTED_EVENT', inboundRequest.Status__c, 'The inbound request should have status UNSUPPORTED_EVENT');
	}

	@isTest
	static void shouldIgnoreEventForUnknownServer() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisChangeEvent__e unknownServerEvent = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Unknown EMR',
			Event__c = 'create',
			ResourceName__c = 'patient',
			ResourceIdentifier__c = '1001'
		);

		Test.startTest();
		ArtemisInboundRequestsService.processEvents(new List<ArtemisChangeEvent__e>{ unknownServerEvent });
		Test.stopTest();

		Assert.areEqual(0, [SELECT COUNT() FROM EmrServerInboundRequest__c], 'There should be no inbound requests logged');
	}
}
