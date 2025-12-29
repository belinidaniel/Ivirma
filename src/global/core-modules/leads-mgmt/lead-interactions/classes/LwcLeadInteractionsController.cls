/**
 * @description  : Controller for Lead Interactions LWC  Provides methods to fetch interaction entries and apply selected changes to the Lead.
 * @author		 : Daniel Belini
 **/
public with sharing class LwcLeadInteractionsController {
	@AuraEnabled(cacheable=true)
	public static List<LeadInteractionEntry> getLeadInteractions(Id leadRecordId, String fieldSetName) {
		List<String> fieldApiNames = new List<String>();
		List<Schema.FieldSetMember> fieldSetFields = new List<Schema.FieldSetMember>();

		Schema.FieldSet fieldSet = getFieldSet(fieldSetName);
		fieldSetFields = fieldSet.getFields();
		fieldApiNames = getFieldApiNames(fieldSetFields);

		if (!fieldApiNames.contains('Lead__c')) {
			fieldApiNames.add('Lead__c');
		}
		if (!fieldApiNames.contains('CreatedDate')) {
			fieldApiNames.add('CreatedDate');
		}
		if (!fieldApiNames.contains('Source__c')) {
			fieldApiNames.add('Source__c');
		}

		String query = buildQuery(fieldApiNames, leadRecordId);
		List<SObject> rawResults = Database.query(query);

		Map<String, LeadInteractionFieldMapping__mdt> fieldMappings = getFieldMappings();
		Map<String, String> fieldMappingsApiNames = new Map<String, String>();
		for (String key : fieldMappings.keySet()) {
			fieldMappingsApiNames.put(key, fieldMappings.get(key).LeadField__r.QualifiedApiName);
		}

		Map<String, Object> leadValues = getLeadCurrentValues(leadRecordId, new List<String>(fieldMappingsApiNames.values()));
		return processResults(rawResults, fieldSetFields, fieldMappings, leadValues);
	}

	@AuraEnabled
	public static Map<String, Object> getLeadCurrentValues(Id leadId, List<String> leadFields) {
		if (leadId == null || leadFields == null || leadFields.isEmpty()) {
			throw new AuraHandledException('Lead Id or fields to query are missing.');
		}

		String query = 'SELECT ' + String.join(leadFields, ',') + ' FROM Lead WHERE Id = :leadId LIMIT 1';
		Lead leadRecord = Database.query(query);

		Map<String, Object> leadValues = new Map<String, Object>();
		for (String field : leadFields) {
			leadValues.put(field, leadRecord.get(field));
		}

		return leadValues;
	}

	private static Schema.FieldSet getFieldSet(String fieldSetName) {
		Map<String, Schema.FieldSet> fsMap = Schema.SObjectType.LeadInteractionEntry__c.FieldSets.getMap();
		if (!fsMap.containsKey(fieldSetName)) {
			throw new AuraHandledException('Missing FieldSet: ' + fieldSetName + '. Please create it on LeadInteractionEntry__c.');
		}
		return fsMap.get(fieldSetName);
	}

	private static List<String> getFieldApiNames(List<Schema.FieldSetMember> fieldSetFields) {
		List<String> fieldApiNames = new List<String>();
		for (Schema.FieldSetMember f : fieldSetFields) {
			fieldApiNames.add(f.getFieldPath());
		}
		return fieldApiNames;
	}

	private static String buildQuery(List<String> fieldApiNames, Id leadRecordId) {
		return 'SELECT ' + String.join(fieldApiNames, ',') + ' FROM LeadInteractionEntry__c WHERE Lead__c = :leadRecordId ORDER BY CreatedDate DESC';
	}

	private static Map<String, LeadInteractionFieldMapping__mdt> getFieldMappings() {
		Map<String, LeadInteractionFieldMapping__mdt> fieldMappings = new Map<String, LeadInteractionFieldMapping__mdt>();
		for (LeadInteractionFieldMapping__mdt mapping : [
			SELECT LeadInteractionField__r.QualifiedApiName, LeadField__r.QualifiedApiName, LeadField__r.Label, MergeBehaviour__c
			FROM LeadInteractionFieldMapping__mdt
		]) {
			String sourceField = mapping.LeadInteractionField__r.QualifiedApiName;
			String targetField = mapping.LeadField__r.QualifiedApiName;

			fieldMappings.put(sourceField, mapping);
		}
		return fieldMappings;
	}

	private static List<LeadInteractionEntry> processResults(
		List<LeadInteractionEntry__c> rawResults,
		List<Schema.FieldSetMember> fieldSetFields,
		Map<String, LeadInteractionFieldMapping__mdt> fieldMappings,
		Map<String, Object> leadValues
	) {
		List<LeadInteractionEntry> results = new List<LeadInteractionEntry>();
		for (LeadInteractionEntry__c interaction : rawResults) {
			LeadInteractionEntry entry = new LeadInteractionEntry();
			entry.id = interaction.Id;
			entry.leadId = interaction.Lead__c;
			entry.createdDate = interaction.CreatedDate;
			entry.source = interaction.Source__c;

			List<LeadInteractionEntryValue> values = new List<LeadInteractionEntryValue>();
			for (Schema.FieldSetMember field : fieldSetFields) {
				String apiName = field.getFieldPath();
				Object value = interaction.get(apiName);
				if (value != null && String.valueOf(value).trim() != '') {
					Boolean isSynchable = fieldMappings.containsKey(apiName);
					String leadFieldApiName = isSynchable ? fieldMappings.get(apiName).LeadField__r.QualifiedApiName : null;
					isSynchable = isSynchable && value != leadValues.get(leadFieldApiName);
					String leadFieldLabel = isSynchable ? fieldMappings.get(apiName).LeadField__r.Label : null;
					String mergeBehaviour = isSynchable ? fieldMappings.get(apiName).MergeBehaviour__c : null;

					if (
						(mergeBehaviour == 'append_with_headerinfo' || mergeBehaviour == 'append') &&
						String.valueOf(leadValues.get(leadFieldApiName)).contains(String.valueOf(value))
					) {
						isSynchable = false;
					}

					values.add(new LeadInteractionEntryValue(apiName, leadFieldApiName, String.valueOf(value), leadFieldLabel, mergeBehaviour, isSynchable));
				}
			}
			entry.values = values;
			results.add(entry);
		}
		return results;
	}

	public class LeadInteractionEntry {
		@AuraEnabled
		public Id id { get; set; }
		@AuraEnabled
		public String leadId { get; set; }
		@AuraEnabled
		public DateTime createdDate { get; set; }
		@AuraEnabled
		public String toISOString {
			get {
				return createdDate != null ? String.valueOf(createdDate.getTime()) : null;
			}
		}
		@AuraEnabled
		public String source { get; set; }
		@AuraEnabled
		public List<LeadInteractionEntryValue> values { get; set; }
	}

	public class LeadInteractionEntryValue {
		@AuraEnabled
		public String fieldApiName { get; set; }
		@AuraEnabled
		public String leadFieldApiName { get; set; }
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public string leadFieldLabel { get; set; }
		@AuraEnabled
		public String mergeBehaviour { get; set; }
		@AuraEnabled
		public Boolean isSynchable { get; set; }

		LeadInteractionEntryValue(
			String fieldApiName,
			String leadFieldApiName,
			String leadFieldValue,
			String leadFieldLabel,
			string mergeBehaviour,
			Boolean isSynchable
		) {
			this.fieldApiName = fieldApiName;
			this.leadFieldApiName = leadFieldApiName;
			this.value = leadFieldValue;
			this.mergeBehaviour = mergeBehaviour;
			this.leadFieldLabel = leadFieldLabel;
			this.isSynchable = isSynchable;
		}
	}
}
