/**
 * @description  : Trigger Handler for handling inbound requests from EMR server
 * @author       : Ivo Rocha
 **/
public inherited sharing class EmrServerInboundRequestTriggerHandler extends TriggerHandler {
	public override void beforeInsert(List<SObject> triggerNew, TriggerContext tc) {
		ArtemisInboundRequestsService.processRequests(triggerNew);
	}
}
