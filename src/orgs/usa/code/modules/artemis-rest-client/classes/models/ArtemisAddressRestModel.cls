/**
 * @description  : This class represents an address in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisAddressRestModel extends EmrRestClient.RestModel {
	@InvocableVariable
	@AuraEnabled
	public String countryCode;

	@InvocableVariable
	@AuraEnabled
	public String stateCode;

	@InvocableVariable
	@AuraEnabled
	public String city;

	@InvocableVariable
	@AuraEnabled
	public String street;

	@InvocableVariable
	@AuraEnabled
	public String zip;

	// @InvocableVariable
	// @AuraEnabled
	// public Double latitude;

	// @InvocableVariable
	// @AuraEnabled
	// public Double longitude;

	public ArtemisAddressRestModel() {
	}

	public ArtemisAddressRestModel(Address address) {
		this.countryCode = address.CountryCode;
		this.stateCode = address.StateCode;
		this.city = address.City;
		this.street = address.Street;
		this.zip = address.PostalCode;
		//this.latitude = address.Latitude;
		//this.longitude = address.Longitude;
	}

	/**
	 * @description  : This method creates an ArtemisAddressRestModel from an Address object.
	 * @param addressDetails The Address standard object to convert.
	 * @return ArtemisAddressRestModel A new ArtemisAddressRestModel instance.
	 */
	public static ArtemisAddressRestModel fromSObject(Address addressDetails) {
		return fromSObject(addressDetails, false);
	}

	/**
	 * @description  : This method creates an ArtemisAddressRestModel from an Address object.
	 * @param addressDetails The Address standard object to convert.
	 * @param nullIfEmpty If true, the method will return null if the addressDetails is empty. Otherwise, a new ArtemisAddressRestModel instance will be returned with empty values.
	 * @return ArtemisAddressRestModel A new ArtemisAddressRestModel instance or null if the addressDetails is empty, depending on the nullIfEmpty parameter.
	 */
	public static ArtemisAddressRestModel fromSObject(Address addressDetails, Boolean nullIfEmpty) {
		if (
			String.isBlank(addressDetails.CountryCode) &&
			String.isBlank(addressDetails.StateCode) &&
			String.isBlank(addressDetails.City) &&
			String.isBlank(addressDetails.Street) &&
			String.isBlank(addressDetails.PostalCode)
		) {
			return nullIfEmpty ? null : new ArtemisAddressRestModel();
		}

		ArtemisAddressRestModel addressModel = new ArtemisAddressRestModel();
		addressModel.countryCode = addressDetails.CountryCode;
		addressModel.stateCode = addressDetails.StateCode;
		addressModel.city = addressDetails.City;
		addressModel.street = addressDetails.Street;
		addressModel.zip = addressDetails.PostalCode;

		return addressModel;
	}
}
