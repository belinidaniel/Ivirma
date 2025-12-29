/**
 * @description  : This class represents a location in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisLocationRestModel extends EmrRestClient.RestModel {
	public String id;
	public String name;
	public String description;
	public ArtemisAddressRestModel address;
	public String phone;
	public String fax;
	public Boolean isRetired;

	public Account toSObject() {
		return toSObject(null);
	}

	public Account toSObject(Id recordId) {
		Account location = new Account(Id = recordId);
		location.RecordTypeId = RecordTypes.ACCOUNT_LOCATION.Id;
		location.Name = this.name;
		location.Description = this.description;
		location.RetiredBusiness__c = this.isRetired != null ? this.isRetired : false;
		location.Phone = this.phone;
		location.Fax = this.fax;

		location.LocationAddress__CountryCode__s = this.address?.countryCode;
		location.LocationAddress__StateCode__s = this.address?.stateCode;
		location.LocationAddress__City__s = this.address?.city;
		location.LocationAddress__Street__s = this.address?.street;
		location.LocationAddress__PostalCode__s = this.address?.zip;

		return location;
	}
}
