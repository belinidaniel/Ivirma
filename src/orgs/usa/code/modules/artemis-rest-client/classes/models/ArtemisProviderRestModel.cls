/**
 * @description  : This class represents a provider in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisProviderRestModel extends EmrRestClient.RestModel {
	public String id;
	public String firstName;
	public String lastName;
	public String middleName;
	public String suffix;
	public String title;
	public String npi;
	public String email;
	public String additionalEmail;
	public List<String> languages;
	public List<String> medicalDegrees;
	public String specialty;
	public ArtemisAddressRestModel address;
	public String phone;
	public String calendarId;

	public Contact toSObject() {
		return toSObject(null);
	}

	public Contact toSObject(Id recordId) {
		Contact contact = new Contact(Id = recordId);
		contact.RecordTypeId = RecordTypes.CONTACT_PROVIDER.Id;
		contact.FirstName = this.firstName;
		contact.MiddleName = this.middleName;
		contact.LastName = this.lastName;
		contact.Suffix = this.suffix;
		contact.Title = this.title;
		contact.ProviderNpi__c = this.npi;
		contact.Email = this.email;
		contact.AdditionalEmail__c = this.additionalEmail;
		contact.ProviderStaffLanguage__c = this.languages != null ? String.join(this.languages, ';') : null;
		contact.ProviderMedicalDegree__c = this.medicalDegrees != null ? String.join(this.medicalDegrees, ';') : null;
		contact.ProviderSpecialty__c = this.specialty;
		contact.Phone = this.phone;

		if (this.address != null) {
			contact.MailingCountryCode = this.address.countryCode;
			contact.MailingStateCode = this.address.stateCode;
			contact.MailingCity = this.address.city;
			contact.MailingStreet = this.address.street;
			contact.MailingPostalCode = this.address.zip;
		}

		return contact;
	}
}
