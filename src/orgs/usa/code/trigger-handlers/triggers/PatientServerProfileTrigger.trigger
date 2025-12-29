/**
 * @description  : Trigger to handle PatientServerProfile object events.
 * @author       : Ivo Rocha
 **/
trigger PatientServerProfileTrigger on PatientServerProfile__c(
	before insert,
	after insert,
	before update,
	after update,
	before delete,
	after delete,
	after undelete
) {
	TriggerDispatcher.run(new PatientServerProfileTriggerHandler());
	Rollup.runFromTrigger();
}
