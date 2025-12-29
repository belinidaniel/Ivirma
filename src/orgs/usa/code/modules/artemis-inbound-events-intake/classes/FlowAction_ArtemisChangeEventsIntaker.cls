/**
 * @description  : Flow action to be used on Process Builder. Allows the processing of ArtemisChangeEvent__e events.
 * 				   It will fetch the resource information back from Artemis and create a new event linked to the EMR server for further processing.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisEventsIntake
 **/
public without sharing class FlowAction_ArtemisChangeEventsIntaker {
	@InvocableMethod(label='Process Artemis Change Events' description='Processes a list of Artemis Change Events' category='Artemis Events')
	public static void processArtemisChangeEvent(List<ArtemisChangeEvent__e> artemisChangeEvents) {
		ArtemisInboundRequestsService.processEvents(artemisChangeEvents);
	}
}
