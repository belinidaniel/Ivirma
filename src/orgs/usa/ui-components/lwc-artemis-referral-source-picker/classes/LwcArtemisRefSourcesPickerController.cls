/**
 * @description  :
 * @author       : Ivo Rocha
 **/
public without sharing class LwcArtemisRefSourcesPickerController {
	@AuraEnabled(cacheable=true)
	public static List<EmrServerReferralSourceMetadata__c> geMetadataReferralSources(String emrServerId) {
		if (String.isBlank(emrServerId)) {
			throw new AuraHandledException('LwcArtemisRefSourcesPickerController.getReferralSources: EMR Server ID cannot be null or empty.');
		}

		return new EmrServerReferralSourceMetadataQuery()
			.byEmrServerId(emrServerId)
			.byField(EmrServerReferralSourceMetadata__c.ReferralCategory__c, '!=', 'Doctor_OBGYN')
			.byField(EmrServerReferralSourceMetadata__c.ReferralCategory__c, '!=', 'Doctor_Non OBGYN')
			.byField(EmrServerReferralSourceMetadata__c.ReferralCategory__c, '!=', 'Acupuncturist')
			.orderBy(EmrServerReferralSourceMetadata__c.ReferralCategory__c, true, false)
			.orderBy(EmrServerReferralSourceMetadata__c.ReferredBy__c, true, true)
			.getList();
	}

	@AuraEnabled(cacheable=true)
	public static List<Contact> getPractitioners(String emrServerId) {
		if (String.isBlank(emrServerId)) {
			throw new AuraHandledException('LwcArtemisRefSourcesPickerController.getPractitioners: EMR Server ID cannot be null or empty.');
		}

		List<EmrServerContactReference__c> practitionerReferences = new EmrServerContactReferenceQuery()
			.byEmrServerId(emrServerId)
			.byField(EmrServerContactReference__c.ArtemisPractitionerIdentifier__c, '!=', null)
			.getList();

		return new ProviderQuery().withErmServerReference(practitionerReferences).getList();
	}
}
