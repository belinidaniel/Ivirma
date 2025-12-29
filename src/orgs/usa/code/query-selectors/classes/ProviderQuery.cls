/**
 * @description  : Query object for Provider (Contact) records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class ProviderQuery extends QueryObject {
	public ProviderQuery() {
		super(
			new List<SObjectField>{
				Contact.Id,
				Contact.OwnerId,
				Contact.RecordTypeId,
				Contact.AccountId,
				Contact.Title,
				Contact.Salutation,
				Contact.Name,
				Contact.FirstName,
				Contact.MiddleName,
				Contact.LastName,
				Contact.Suffix,
				Contact.ProviderMedicalDegree__c,
				Contact.ProviderSpecialty__c,
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
				Contact.AdditionalEmail__c,
				Contact.ProviderNpi__c
			},
			Contact.SObjectType
		);
		byRecordTypeId(RecordTypes.CONTACT_PROVIDER.Id);
	}

	public ProviderQuery withErmServerReference(EmrServerContactReference__c ermReference) {
		return withErmServerReference(new List<EmrServerContactReference__c>{ ermReference });
	}

	public ProviderQuery withErmServerReference(List<EmrServerContactReference__c> ermReferences) {
		return (ProviderQuery) relatedToChildren(ermReferences, EmrServerContactReference__c.Contact__c);
	}

	public ProviderQuery byNpi(String npi) {
		return byNpi(new Set<String>{ npi });
	}

	public ProviderQuery byNpi(Set<String> npis) {
		return (ProviderQuery) byField(Contact.ProviderNpi__c, 'IN', npis);
	}

	public ProviderQuery byNonEmptyNpi() {
		return (ProviderQuery) byField(Contact.ProviderNpi__c, '!=', null);
	}
}
