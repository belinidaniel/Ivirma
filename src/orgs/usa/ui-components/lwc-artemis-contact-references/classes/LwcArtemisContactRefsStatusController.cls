/**
 * @description  :
 * @author       : Ivo Rocha
 **/
public class LwcArtemisContactRefsStatusController {
	/**
	 * @description
	 * @param entityId
	 * @return List<ContactServerReference>
	 **/
	@AuraEnabled(cacheable=true)
	public static List<ContactServerReference> getContactReferences(Id contactId) {
		if (contactId == null) {
			throw new AuraHandledException('contactId parameter cannot be null.');
		}

		// Create a map of existing references for easy lookup
		Map<Id, ContactServerReference> existingReferencesMap = new Map<Id, ContactServerReference>();
		for (ContactServerReference ref : getExistingReferences(contactId)) {
			existingReferencesMap.put(ref.serverId, ref);
		}

		// Get all EMR Server records
		List<EMRServer__c> allServers = (List<EMRServer__c>) new EmrServerQuery().getList();

		List<ContactServerReference> result = new List<ContactServerReference>();
		// Iterate through all servers and add missing ones (servers where this entity does not exist or reference is missing) with default values
		for (EMRServer__c server : allServers) {
			if (existingReferencesMap.containsKey(server.Id)) {
				result.add(existingReferencesMap.get(server.Id));
			} else {
				// Create a dummy empty ContactServerReference entry
				ContactServerReference dummyReference = new ContactServerReference(contactId, server.Name, server.Id);
				result.add(dummyReference);
			}
		}

		// Sort the entityReferences array so that records with references come first
		result.sort();

		return result;
	}

	//@AuraEnabled
	//public static void createEntityReference(Id entityId, Id emrServerId, String reference) {
	// if (entityId == null) {
	// 	throw new AuraHandledException('Entity Id parameter cannot be null.');
	// }

	// if (entityId.getSObjectType() != Account.getSObjectType() && entityId.getSObjectType() != Contact.getSObjectType()) {
	// 	throw new AuraHandledException('Entity Id can only be of Account or Contact types');
	// }

	// if (entityId.getSObjectType() == Account.getSObjectType()) {
	// 	EmrServerAccountReference__c refRecord = new EmrServerAccountReference__c();
	// 	refRecord.EmrServer__c = emrServerId;
	// 	refRecord.Account__c = entityId;
	// 	refRecord.Identifier__c = reference;
	// 	insert refRecord;
	// }

	// if (entityId.getSObjectType() == Contact.getSObjectType()) {
	// 	EmrServerContactReference__c refRecord = new EmrServerContactReference__c();
	// 	refRecord.EmrServer__c = emrServerId;
	// 	refRecord.Contact__c = entityId;
	// 	refRecord.Identifier__c = reference;
	// 	insert refRecord;
	// }
	//}

	private static List<ContactServerReference> getExistingReferences(Id contactId) {
		List<EmrServerContactReference__c> contactReferences = (List<EmrServerContactReference__c>) new EmrServerContactReferenceQuery()
			.byContactId(contactId)
			.getList();

		List<ContactServerReference> references = new List<ContactServerReference>();
		for (EmrServerContactReference__c refRecord : contactReferences) {
			references.add(new ContactServerReference(refRecord));
		}

		return references;
	}

	public class ContactServerReference implements Comparable {
		@AuraEnabled
		public String entityId { get; set; }
		@AuraEnabled
		public String serverName { get; set; }
		@AuraEnabled
		public String serverId { get; set; }
		@AuraEnabled
		public String serverUrl { get; set; }
		@AuraEnabled
		public String identifier { get; set; }
		@AuraEnabled
		public String practitionerIdentifier { get; set; }
		@AuraEnabled
		public String referralIdentifier { get; set; }
		@AuraEnabled
		public DateTime lastSync { get; set; }

		public ContactServerReference(Id entityId, String serverName, Id serverId) {
			this.entityId = entityId;
			this.serverName = serverName;
			this.serverId = serverId;
			this.serverUrl = '/' + this.serverId;
		}

		public ContactServerReference(EmrServerContactReference__c refRecord) {
			this.entityId = refRecord.Contact__c;
			this.serverName = refRecord.EmrServer__r.Name;
			this.serverId = refRecord.EmrServer__c;
			this.serverUrl = '/' + this.serverId;
			this.identifier = refRecord.Identifier__c;
			this.referralIdentifier = refRecord.ArtemisReferralSourceIdentifier__c;
			this.practitionerIdentifier = refRecord.ArtemisPractitionerIdentifier__c;
			this.lastSync = refRecord.LastSyncDateTime__c;
		}

		public Integer compareTo(Object compareTo) {
			ContactServerReference compareToRef = (ContactServerReference) compareTo;
			if (this.identifier != null && compareToRef.identifier == null) {
				return -1;
			} else if (this.identifier == null && compareToRef.identifier != null) {
				return 1;
			}
			return 0;
		}
	}
}
