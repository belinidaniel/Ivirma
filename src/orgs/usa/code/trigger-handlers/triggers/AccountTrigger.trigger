/**
 * @description  : Trigger to handle Account object events.
 * @author       : Ivo Rocha
 **/
trigger AccountTrigger on Account(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	TriggerDispatcher.run(new AccountTriggerHandler());
}
