/**
 * @description  : Trigger to handle EmrServerInboundRequest__c object events.
 * @author       : Ivo Rocha
 **/
trigger EmrServerInboundRequestTrigger on EmrServerInboundRequest__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerDispatcher.run(new EmrServerInboundRequestTriggerHandler());
}
