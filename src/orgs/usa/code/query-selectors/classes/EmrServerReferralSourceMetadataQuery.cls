/**
 * @description  : This class is used to query the EmrServerReferralSourceMetadata__c object.
 * @author       : Ivo Rocha
 **/
public inherited sharing class EmrServerReferralSourceMetadataQuery extends QueryObject {
	public EmrServerReferralSourceMetadataQuery() {
		super(
			new List<SObjectField>{
				EmrServerReferralSourceMetadata__c.Id,
				EmrServerReferralSourceMetadata__c.EmrServer__c,
				EmrServerReferralSourceMetadata__c.ReferralCategory__c,
				EmrServerReferralSourceMetadata__c.ReferralCategoryInternalId__c,
				EmrServerReferralSourceMetadata__c.ReferralSourceInternalId__c,
				EmrServerReferralSourceMetadata__c.ReferredBy__c
			},
			EmrServerReferralSourceMetadata__c.SObjectType
		);
	}

	public EmrServerReferralSourceMetadataQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public EmrServerReferralSourceMetadataQuery byEmrServerId(Set<Id> emrServerIds) {
		return (EmrServerReferralSourceMetadataQuery) byField(EmrServerReferralSourceMetadata__c.EmrServer__c, 'IN', emrServerIds);
	}

	public EmrServerReferralSourceMetadataQuery byExternalId(String externalId) {
		return byExternalId(new Set<String>{ externalId });
	}

	public EmrServerReferralSourceMetadataQuery byExternalId(Set<String> externalIds) {
		return (EmrServerReferralSourceMetadataQuery) byField(EmrServerReferralSourceMetadata__c.ReferralSourceInternalId__c, 'IN', externalIds);
	}
}
