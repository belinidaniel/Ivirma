/**
 * @description  : This plugin is used to find an existing matching lead and perform post-processing on the inbound lead after it has been converted to a lead and/or a lead interaction entry. Overrides the default behavior of the InboundLeadConversion class.
 * @author       : Daniel Belini
 **/
public with sharing class InboundLeadConversionPluginImpl implements InboundLeadConversion.IPluginMatchingLead, InboundLeadConversion.IPluginPostProcessing {
	public Id findExistingMatchingLead(InboundLead__c inboundLead) {
		return Query.of(
				[
					SELECT Id
					FROM Lead
					WHERE Email = :inboundLead.Email__c AND Brand__c = :inboundLead.Brand__c AND IsConverted = FALSE
					LIMIT 1
				]
			)
			.getFirstIdOrNull();
	}

	public void postProcess(InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord) {
		//If the lead already exists and its status is 'Unqualified', we need to "reopen it" by setting the status to 'New'
		if (lead.Id != null && lead.Status == 'Unqualified') {
			lead.Status = 'New';
		}
	}
}
