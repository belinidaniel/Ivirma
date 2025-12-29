/**
 * @description  : This class represents the metadata referral source model for the EMR Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisMetadataReferralSourceRestModel extends EmrRestClient.RestModel {
	public String id { get; set; }
	public String refBy { get; set; }
	public ReferenceCategory refCat { get; set; }

	public ArtemisMetadataReferralSourceRestModel() {
	}

	public EmrServerReferralSourceMetadata__c toSObject() {
		return toSObject(null);
	}

	public EmrServerReferralSourceMetadata__c toSObject(Id recordId) {
		EmrServerReferralSourceMetadata__c refSourceMetadataRecord = new EmrServerReferralSourceMetadata__c(Id = recordId);
		refSourceMetadataRecord.ReferralSourceInternalId__c = this.id;
		refSourceMetadataRecord.ReferredBy__c = this.refBy;
		refSourceMetadataRecord.ReferralCategory__c = this.refCat?.name;
		refSourceMetadataRecord.ReferralCategoryInternalId__c = this.refCat?.id;
		return refSourceMetadataRecord;
	}

	public Boolean equals(EmrServerReferralSourceMetadata__c refSourceMetadata) {
		return refSourceMetadata != null &&
			this.refCat != null &&
			this.refCat.name == refSourceMetadata.ReferralCategory__c &&
			this.refCat.id == refSourceMetadata.ReferralCategoryInternalId__c &&
			this.id == refSourceMetadata.ReferralSourceInternalId__c &&
			this.refBy == refSourceMetadata.ReferredBy__c;
	}

	public class ReferenceCategory {
		public String id { get; set; }
		public String name { get; set; }
	}
}
