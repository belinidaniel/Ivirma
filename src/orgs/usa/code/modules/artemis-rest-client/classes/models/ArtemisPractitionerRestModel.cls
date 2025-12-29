/**
 * @description  : This class represents a practitioner in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisPractitionerRestModel extends EmrRestClient.RestModel {
	public String id;
	public String firstName;
	public String lastName;
	public String middleName;
	public String suffix;
	public String title;
	public String npi;
	public String email;
	public String additionalEmail;
	//public List<String> languages;
	//public List<String> medicalDegrees;
	public String specialty;
	public ArtemisAddressRestModel address;
	public String phone;

	public Contact toSObject() {
		return toSObject(null);
	}

	public Contact toSObject(Id recordId) {
		Contact contact = new Contact(Id = recordId);
		contact.RecordTypeId = RecordTypes.CONTACT_PROVIDER.Id;
		contact.FirstName = firstName;
		contact.MiddleName = middleName;
		contact.LastName = lastName;
		contact.Suffix = suffix;
		contact.Title = title;
		contact.ProviderNpi__c = npi;
		contact.Email = email;
		contact.AdditionalEmail__c = additionalEmail;
		contact.Phone = phone;
		contact.ProviderSpecialty__c = specialty;

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
