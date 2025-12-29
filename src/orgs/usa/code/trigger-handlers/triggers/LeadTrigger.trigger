/**
 * @description  : Trigger to handle Lead object events.
 * @author       : Ivo Rocha
 **/
trigger LeadTrigger on Lead(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	TriggerDispatcher.run(new LeadTriggerHandler());
}
