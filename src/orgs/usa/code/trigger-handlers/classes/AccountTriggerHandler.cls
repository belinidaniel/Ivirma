/**
 * @description  : Trigger handler for Account object.
 * @author       : Ivo Rocha
 **/
public inherited sharing class AccountTriggerHandler extends TriggerHandler {
	public override void afterInsert(List<SObject> triggerNew, TriggerContext tc) {
		// example maniulation code
		// service classes should be used to manipulate data
		for (Account account : (List<Account>) triggerNew) {
			Account oldAccount = (Account) tc.getOld(account);

			if (tc.isChanged(account, Schema.Account.Name)) {
				System.debug('Account Name changed to: ' + account.Name);
			}
			if (oldAccount?.Name != account.Name) {
				System.debug('Account Name changed to: ' + account.Name);
			}
			if (tc.isChangedFrom(account, Schema.Account.Type, 'Prospect')) {
				System.debug('Account Type changed from Prospect to: ' + account.Type);
			}
			System.debug('Account inserted: ' + account.Id);
		}
	}
}
