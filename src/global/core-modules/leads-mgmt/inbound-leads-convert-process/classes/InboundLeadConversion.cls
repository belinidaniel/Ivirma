/**
 * @description  : This class is responsible for converting inbound leads to leads/lead interaction entries. A DefaultPluginImpl is used to provide the default behavior, but a custom plugin can be used to override the default behavior.
 * @author       : Ivo Rocha
 * @testSuite    : InboundLeadsProcessing
 **/
public without sharing class InboundLeadConversion {
	public static final String INBOUND_LEAD_CONVERSION_PLUGIN_NAME = 'InboundLeadConversionPluginImpl'; //This is the name of the class that must exist in the org, if that org wants to override the default behaviors
	private static Map<String, List<InboundLeadFieldMapping__mdt>> FIELD_MAPPINGS_CACHE;
	static {
		FIELD_MAPPINGS_CACHE = new Map<String, List<InboundLeadFieldMapping__mdt>>();
		FIELD_MAPPINGS_CACHE.put(
			'Lead',
			[
				SELECT InboundLeadField__r.QualifiedApiName, LeadField__r.QualifiedApiName
				FROM InboundLeadFieldMapping__mdt
				WHERE InboundLeadObject__r.QualifiedApiName = 'InboundLead__c' AND LeadObject__r.QualifiedApiName = 'Lead'
			]
		);
		FIELD_MAPPINGS_CACHE.put(
			'LeadInteractionEntry__c',
			[
				SELECT InboundLeadField__r.QualifiedApiName, LeadField__r.QualifiedApiName
				FROM InboundLeadFieldMapping__mdt
				WHERE InboundLeadObject__r.QualifiedApiName = 'InboundLead__c' AND LeadObject__r.QualifiedApiName = 'LeadInteractionEntry__c'
			]
		);
	}

	public List<InboundLead__c> inboundLeads { get; private set; }

	@testVisible
	private DefaultPluginImpl defaultPlugin;

	@testVisible
	private Type customPluginType;

	/**
	 * @description Constructor for the InboundLeadConversion class.
	 * @param inboundLeadIds The set of inbound lead IDs to process.
	 */
	public InboundLeadConversion(Set<Id> inboundLeadIds) {
		this(Query.fromSObject(InboundLead__c.SObjectType).withAllFields().byId(inboundLeadIds).getList());
	}

	/**
	 * @description Constructor for the InboundLeadConversion class.
	 * @param inboundLeads The list of inbound leads to process.
	 */
	public InboundLeadConversion(List<InboundLead__c> inboundLeads) {
		this.inboundLeads = inboundLeads;
		this.defaultPlugin = new DefaultPluginImpl();
		this.customPluginType = Type.forName(INBOUND_LEAD_CONVERSION_PLUGIN_NAME);
	}

	/**
	 * @description Converts the inbound leads to leads and creates lead interaction entries.
	 * @return A list of InboundLeadConversionResult objects, one for each inbound lead.
	 */
	public List<InboundLeadConversionResult> convert() {
		return convert(true);
	}

	/**
	 * @description Converts the inbound leads to leads and creates lead interaction entries.
	 * @param commitResults If true, the results of the conversion will be saved on the inbound leads.
	 * @return A list of InboundLeadConversionResult objects, one for each inbound lead.
	 */
	public List<InboundLeadConversionResult> convert(Boolean commitResults) {
		List<InboundLeadConversionResult> results = new List<InboundLeadConversionResult>();
		for (InboundLead__c inboundLead : this.inboundLeads) {
			InboundLeadConversionResult result = processInboundLead(inboundLead);

			if (result.success) {
				inboundLead.ProcessingStatus__c = 'Processed';
				inboundLead.ProcessingReason__c = null;
				inboundLead.ConvertedToLead__c = result.resultLead.Id;
				inboundLead.ConvertedToInteractionLeadEntry__c = result.resultLeadInteractionEntry.Id;
			} else {
				inboundLead.ProcessingStatus__c = 'Error';
				inboundLead.ProcessingReason__c = result.errorMessage;
			}

			results.add(result);
		}

		if (commitResults) {
			update this.inboundLeads;
		}

		return results;
	}

	/**
	 * @description Processes a single inbound lead, converting it to a lead and creating a lead interaction entry.
	 * @param inboundLead The inbound lead to process.
	 */
	private InboundLeadConversionResult processInboundLead(final InboundLead__c inboundLead) {
		DatabaseUnitOfWork uow = new DatabaseUnitOfWork();
		uow.withDMLOptions(new DMLOptionsBuilder().allowDuplicates(true).allOrNone(true).build());

		Id leadId = findExistingMatchingLead(inboundLead);
		Lead leadRecord;
		if (leadId == null) {
			leadRecord = createLeadRecord(inboundLead);
			uow.insertRecord(leadRecord);
		} else {
			leadRecord = (Lead) Query.fromSObject(Lead.SObjectType).withAllFields().byId(leadId).forUpdate().getFirst();
			uow.updateRecord(leadRecord); //register an update operation for the lead, so it can be updated if needed in the post processing method.
		}

		LeadInteractionEntry__c leadIteractionEntry = createLeadInteractionEntryRecord(inboundLead);
		uow.insertRecord(leadIteractionEntry, LeadInteractionEntry__c.Lead__c, leadRecord);

		Id existingCampaignId = findExistingCampaign(inboundLead);
		CampaignMember newCampaignMemberRecord;
		if (existingCampaignId != null) {
			Boolean campaignMemberAlreadyExists = false;
			if (leadId != null) {
				campaignMemberAlreadyExists =
					Query.fromSObject(CampaignMember.SObjectType)
						.byField(CampaignMember.CampaignId, '=', existingCampaignId)
						.byField(CampaignMember.LeadId, '=', leadId)
						.getFirstOrNull() != null;
			}

			if (campaignMemberAlreadyExists == false) {
				newCampaignMemberRecord = new CampaignMember(CampaignId = existingCampaignId);
				uow.insertRecord(newCampaignMemberRecord, CampaignMember.LeadId, leadRecord);
			}
		}

		// custom plugin post processing. It can modify the lead or the lead interaction entry and its changes will be saved upon the commitWork() call.
		postProcessing(inboundLead, leadRecord, leadIteractionEntry, newCampaignMemberRecord);

		try {
			uow.commitWork();

			// custom plugin post commit.
			postCommit(inboundLead, leadRecord, leadIteractionEntry, newCampaignMemberRecord);

			return new InboundLeadConversionResult(leadRecord, leadIteractionEntry);
		} catch (Exception ex) {
			return new InboundLeadConversionResult(false, ex.getMessage() + '\n\n' + ex.getStackTraceString());
		}
	}

	/**
	 * Creates a new Lead record based on the inbound lead data and the existing field mapping configuration.
	 *
	 * @param inboundLead The inbound lead to create the Lead record from.
	 * @return The created Lead record.
	 */
	private Lead createLeadRecord(InboundLead__c inboundLead) {
		List<InboundLeadFieldMapping__mdt> mappings = FIELD_MAPPINGS_CACHE.get('Lead');

		Lead newLead = new Lead();
		for (InboundLeadFieldMapping__mdt mapping : mappings) {
			String sourceField = String.valueOf(mapping.InboundLeadField__r.QualifiedApiName);
			String targetField = String.valueOf(mapping.LeadField__r.QualifiedApiName);

			if (String.isNotBlank(sourceField) && String.isNotBlank(targetField)) {
				if (inboundLead.getPopulatedFieldsAsMap().containsKey(sourceField)) {
					Object value = inboundLead.get(sourceField);
					if (value != null) {
						// Check the data type of the target field and convert if necessary
						Schema.SObjectField targetFieldSchema = Lead.SObjectType.getDescribe().fields.getMap().get(targetField);
						Schema.DisplayType targetFieldType = targetFieldSchema.getDescribe().getType();

						if (targetFieldType == Schema.DisplayType.Date && value instanceof String) {
							// Convert String to Date
							newLead.put(targetField, Date.valueOf((String) value));
						} else if (targetFieldType == Schema.DisplayType.DateTime && value instanceof String) {
							// Convert String to DateTime
							newLead.put(targetField, DateTime.valueOf((String) value));
						} else {
							// Default assignment
							newLead.put(targetField, value);
						}
					}
				}
			}
		}

		if (String.isBlank(newLead.LeadSource)) {
			newLead.LeadSource = 'Inbound';
		}

		return newLead;
	}

	/**
	 * Creates a new LeadInteractionEntry__c record based on the inbound lead data and the existing field mapping configuration.
	 *
	 * @param inboundLead The inbound lead to create the LeadInteractionEntry__c record from.
	 * @return The created LeadInteractionEntry__c record.
	 */
	private LeadInteractionEntry__c createLeadInteractionEntryRecord(InboundLead__c inboundLead) {
		List<InboundLeadFieldMapping__mdt> mappings = FIELD_MAPPINGS_CACHE.get('LeadInteractionEntry__c');

		LeadInteractionEntry__c interaction = new LeadInteractionEntry__c();
		for (InboundLeadFieldMapping__mdt mapping : mappings) {
			String sourceField = String.valueOf(mapping.InboundLeadField__r.QualifiedApiName);
			String targetField = String.valueOf(mapping.LeadField__r.QualifiedApiName);

			if (String.isNotBlank(sourceField) && String.isNotBlank(targetField)) {
				if (inboundLead.getPopulatedFieldsAsMap().containsKey(sourceField)) {
					Object value = inboundLead.get(sourceField);
					if (value != null) {
						// Check the data type of the target field and convert if necessary
						Schema.SObjectField targetFieldSchema = LeadInteractionEntry__c.SObjectType.getDescribe().fields.getMap().get(targetField);
						Schema.DisplayType targetFieldType = targetFieldSchema.getDescribe().getType();

						if (targetFieldType == Schema.DisplayType.Date && value instanceof String) {
							// Convert String to Date
							interaction.put(targetField, Date.valueOf((String) value));
						} else if (targetFieldType == Schema.DisplayType.DateTime && value instanceof String) {
							// Convert String to DateTime
							interaction.put(targetField, DateTime.valueOf((String) value));
						} else {
							// Default assignment
							interaction.put(targetField, value);
						}
					}
				}
			}
		}

		return interaction;
	}

	/**
	 * Finds an existing matching lead that matches the inbound lead.
	 *
	 * @param inboundLead The inbound lead to find a matching lead for.
	 * @return The ID of the existing matching lead, or null if no matching lead is found.
	 */
	private Id findExistingMatchingLead(InboundLead__c inboundLead) {
		Type customPluginInterface = Type.forName('InboundLeadConversion.IPluginMatchingLead');
		if (this.customPluginType != null && customPluginInterface.isAssignableFrom(this.customPluginType)) {
			// Use the custom plugin to find the existing matching lead
			return ((IPluginMatchingLead) this.customPluginType.newInstance()).findExistingMatchingLead(inboundLead);
		}

		return defaultPlugin.findExistingMatchingLead(inboundLead);
	}

	/**
	 * Finds an existing campaign that matches the inbound lead.
	 *
	 * @param inboundLead The inbound lead to find a matching campaign for.
	 * @return The ID of the existing campaign that matches the inbound lead, or null if no matching campaign is found.
	 */
	private Id findExistingCampaign(InboundLead__c inboundLead) {
		Type customPluginInterface = Type.forName('InboundLeadConversion.IPluginMatchingCampaign');
		if (this.customPluginType != null && customPluginInterface.isAssignableFrom(this.customPluginType)) {
			// Use the custom plugin to find the existing matching campaign
			return ((IPluginMatchingCampaign) this.customPluginType.newInstance()).findExistingCampaign(inboundLead);
		}
		return defaultPlugin.findExistingCampaign(inboundLead);
	}

	/**
	 * Performs post-processing on the inbound lead after it has been converted to a lead.
	 *
	 * @param inboundLead The inbound lead that has been converted to a lead.
	 * @param lead The lead that has been created from the inbound lead.
	 * @param leadInteractionEntry The lead interaction entry that has been created from the inbound lead.
	 */
	private void postProcessing(InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord) {
		Type customPluginInterface = Type.forName('InboundLeadConversion.IPluginPostProcessing');
		if (this.customPluginType != null && customPluginInterface.isAssignableFrom(this.customPluginType)) {
			// Use the custom plugin to find the existing matching lead
			((IPluginPostProcessing) this.customPluginType.newInstance()).postProcess(inboundLead, lead, leadInteractionEntry, campaignMemberRecord);
		} else {
			defaultPlugin.postProcess(inboundLead, lead, leadInteractionEntry, campaignMemberRecord);
		}
	}

	/**
	 * Performs post-commit processing on the inbound lead after it has been converted to a lead and/or a lead interaction entry.
	 *
	 * @param inboundLead The inbound lead that has been converted to a lead.
	 * @param lead The lead that has been created from the inbound lead.
	 * @param leadInteractionEntry The lead interaction entry that has been created from the inbound lead.
	 */
	private void postCommit(InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord) {
		Type customPluginInterface = Type.forName('InboundLeadConversion.IPluginPostCommit');
		if (this.customPluginType != null && customPluginInterface.isAssignableFrom(this.customPluginType)) {
			((IPluginPostCommit) this.customPluginType.newInstance()).postCommit(inboundLead, lead, leadInteractionEntry, campaignMemberRecord);
		} else {
			defaultPlugin.postCommit(inboundLead, lead, leadInteractionEntry, campaignMemberRecord);
		}
	}

	/**
	 * Default implementation of the plugin interfaces. This class provides default behavior for finding existing leads and campaigns,
	 * as well as post-processing after lead conversion.
	 */
	public class DefaultPluginImpl implements IPluginMatchingLead, IPluginMatchingCampaign, IPluginPostProcessing, IPluginPostCommit {
		public Id findExistingMatchingLead(final InboundLead__c inboundLead) {
			return Query.of(
					[
						SELECT Id
						FROM Lead
						WHERE Email = :inboundLead.Email__c AND IsConverted = FALSE
						LIMIT 1
					]
				)
				.getFirstIdOrNull();
		}

		public Id findExistingCampaign(final InboundLead__c inboundLead) {
			String reference = inboundLead.CampaignReference__c;
			if (String.isNotBlank(reference)) {
				return Query.of(
						[
							SELECT Id
							FROM Campaign
							WHERE Name = :reference OR Id = :reference
							LIMIT 1
						]
					)
					.getFirstIdOrNull();
			}
			return null;
		}

		public void postProcess(
			final InboundLead__c inboundLead,
			Lead lead,
			LeadInteractionEntry__c leadInteractionEntry,
			CampaignMember campaignMemberRecord
		) {
			// Default implementation does nothing
		}

		public void postCommit(final InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord) {
			// Default implementation does nothing
		}
	}

	/**
	 * @description Interface for the plugin that finds an existing matching lead.
	 */
	public interface IPluginMatchingLead {
		Id findExistingMatchingLead(final InboundLead__c inboundLead);
	}

	/**
	 * @description Interface for the plugin that finds an existing matching campaign.
	 */
	public interface IPluginMatchingCampaign {
		Id findExistingCampaign(final InboundLead__c inboundLead);
	}

	/**
	 * @description Interface for the plugin that performs post-processing on the inbound lead after it has been converted to a lead and/or a lead interaction entry.
	 */
	public interface IPluginPostProcessing {
		void postProcess(final InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord);
	}

	/**
	 * @description Interface for the plugin that performs post-commit processing on the inbound lead after it has been converted to a lead and/or a lead interaction entry.
	 */
	public interface IPluginPostCommit {
		void postCommit(final InboundLead__c inboundLead, Lead lead, LeadInteractionEntry__c leadInteractionEntry, CampaignMember campaignMemberRecord);
	}

	public class InboundLeadConversionResult {
		public Boolean success { get; set; }
		public String errorMessage { get; set; }
		public Lead resultLead { get; set; }
		public LeadInteractionEntry__c resultLeadInteractionEntry { get; set; }

		public InboundLeadConversionResult(Lead lead, LeadInteractionEntry__c leadInteractionEntry) {
			this();
			this.resultLead = lead;
			this.resultLeadInteractionEntry = leadInteractionEntry;
		}

		public InboundLeadConversionResult(Boolean success, String errorMessage) {
			this.success = success;
			this.errorMessage = errorMessage;
		}

		public InboundLeadConversionResult() {
			this.success = true;
		}
	}
}
