/**
 * @description  : Query object for Staff (Contact) records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class StaffQuery extends QueryObject {
	public StaffQuery() {
		super(
			new List<SObjectField>{
				Contact.Id,
				Contact.OwnerId,
				Contact.RecordTypeId,
				Contact.AccountId,
				Contact.Title,
				Contact.Salutation,
				Contact.FirstName,
				Contact.MiddleName,
				Contact.LastName,
				Contact.Suffix,
				Contact.ProviderMedicalDegree__c, //Is this part of staff too?
				Contact.ProviderSpecialty__c, //Is this part of staff too?
				Contact.ProviderStaffLanguage__c,
				Contact.MailingCountryCode,
				Contact.MailingStateCode,
				Contact.MailingCity,
				Contact.MailingStreet,
				Contact.MailingPostalCode,
				Contact.Phone,
				Contact.MobilePhone,
				Contact.Fax,
				Contact.Email,
				Contact.AdditionalEmail__c
			},
			Contact.SObjectType
		);
		byRecordTypeId(RecordTypes.CONTACT_STAFF.Id);
	}
}
