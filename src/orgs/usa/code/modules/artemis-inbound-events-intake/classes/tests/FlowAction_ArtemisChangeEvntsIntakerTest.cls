/**
 * @description       : Unit tests for the FlowAction_ArtemisChangeEventsIntaker class.
 * @author            : Ivo Rocha
 * @testSuite         : ArtemisEventsIntake
 **/
@isTest
private class FlowAction_ArtemisChangeEvntsIntakerTest {
	@TestSetup
	static void makeData() {
		ArtemisRestClientTest.makeData();
	}

	@isTest
	static void testProcessArtemisChangeEvent() {
		Test.setMock(HttpCalloutMock.class, HttpMocks.config());

		ArtemisChangeEvent__e event = new ArtemisChangeEvent__e(
			ArtemisServer__c = 'Artemis EMR',
			Event__c = 'create',
			ResourceName__c = 'patient',
			ResourceIdentifier__c = '1234567890'
		);

		Test.startTest();
		FlowAction_ArtemisChangeEventsIntaker.processArtemisChangeEvent(new List<ArtemisChangeEvent__e>{ event });
		Test.stopTest();

		Assert.areEqual(1, [SELECT COUNT() FROM EmrServerInboundRequest__c], 'There should be one inbound request logged');
	}
}
