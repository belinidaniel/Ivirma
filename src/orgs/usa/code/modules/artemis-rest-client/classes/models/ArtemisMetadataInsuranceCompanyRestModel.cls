/**
 * @description  : This class represents an insurance company metadata in the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisMetadataInsuranceCompanyRestModel extends EmrRestClient.RestModel {
	public String id { get; set; }
	public String name { get; set; }

	public ArtemisMetadataInsuranceCompanyRestModel() {
	}

	public EmrServerInsuranceCompanyMetadata__c toSObject() {
		return toSObject(null);
	}

	public EmrServerInsuranceCompanyMetadata__c toSObject(Id recordId) {
		EmrServerInsuranceCompanyMetadata__c insuranceCompanyMetadataRecord = new EmrServerInsuranceCompanyMetadata__c(Id = recordId);
		insuranceCompanyMetadataRecord.InsuranceCompanyInternalId__c = this.id;
		insuranceCompanyMetadataRecord.Name = this.name;
		return insuranceCompanyMetadataRecord;
	}

	public Boolean equals(EmrServerInsuranceCompanyMetadata__c insuranceCompanyMetadataRecord) {
		return insuranceCompanyMetadataRecord != null &&
			this.id == insuranceCompanyMetadataRecord.InsuranceCompanyInternalId__c &&
			this.name == insuranceCompanyMetadataRecord.Name;
	}
}
