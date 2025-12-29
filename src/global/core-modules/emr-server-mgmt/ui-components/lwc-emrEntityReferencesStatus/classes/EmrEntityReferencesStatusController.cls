/**
 * @description  :
 * @author       : Ivo Rocha
 **/
public class EmrEntityReferencesStatusController {
	/**
	 * @description
	 * @param entityId
	 * @return List<EntityServerReference>
	 **/
	@AuraEnabled(cacheable=true)
	public static List<EntityServerReference> getEntityReferences(Id entityId) {
		if (entityId == null) {
			throw new AuraHandledException('Entity Id parameter cannot be null.');
		}

		if (entityId.getSObjectType() != Account.getSObjectType() && entityId.getSObjectType() != Contact.getSObjectType()) {
			throw new AuraHandledException('Entity Id can only be of Account or Contact types');
		}

		List<EntityServerReference> result = new List<EntityServerReference>();

		// Create a map of existing references for easy lookup
		Map<Id, EntityServerReference> existingReferencesMap = new Map<Id, EntityServerReference>();
		for (EntityServerReference ref : getExistingReferences(entityId)) {
			existingReferencesMap.put(ref.serverId, ref);
		}

		// Get all EMR Server records
		List<EMRServer__c> allServers = [SELECT Id, Name FROM EMRServer__c];

		// Iterate through all servers and add missing ones (servers where this entity does not exist or reference is missing) with default values
		for (EMRServer__c server : allServers) {
			if (existingReferencesMap.containsKey(server.Id)) {
				result.add(existingReferencesMap.get(server.Id));
			} else {
				// Create a dummy empty EntityServerReference entry
				EntityServerReference dummyReference = new EntityServerReference(
					entityId.getSObjectType().getDescribe().getLocalName(),
					entityId,
					server.Name,
					server.Id,
					null,
					null,
					false
				);
				result.add(dummyReference);
			}
		}

		// Sort the entityReferences array so that records with references come first
		result.sort();

		return result;
	}

	@AuraEnabled
	public static void createEntityReference(Id entityId, Id emrServerId, String reference) {
		if (entityId == null) {
			throw new AuraHandledException('Entity Id parameter cannot be null.');
		}

		if (entityId.getSObjectType() != Account.getSObjectType() && entityId.getSObjectType() != Contact.getSObjectType()) {
			throw new AuraHandledException('Entity Id can only be of Account or Contact types');
		}

		if (entityId.getSObjectType() == Account.getSObjectType()) {
			EmrServerAccountReference__c refRecord = new EmrServerAccountReference__c();
			refRecord.EmrServer__c = emrServerId;
			refRecord.Account__c = entityId;
			refRecord.Identifier__c = reference;
			insert refRecord;
		}

		if (entityId.getSObjectType() == Contact.getSObjectType()) {
			EmrServerContactReference__c refRecord = new EmrServerContactReference__c();
			refRecord.EmrServer__c = emrServerId;
			refRecord.Contact__c = entityId;
			refRecord.Identifier__c = reference;
			insert refRecord;
		}
	}

	private static List<EntityServerReference> getExistingReferences(Id entityId) {
		List<EntityServerReference> references = new List<EntityServerReference>();
		if (entityId.getSObjectType() == Account.getSObjectType()) {
			List<EmrServerAccountReference__c> accountReferences = [
				SELECT Id, Name, Account__c, Identifier__c, CreatedDate, EmrServer__c, EmrServer__r.Name, LastSyncDateTime__c, IsPrimary__c
				FROM EmrServerAccountReference__c
				WHERE Account__c = :entityId
			];
			for (EmrServerAccountReference__c refRecord : accountReferences) {
				references.add(new EntityServerReference(refRecord));
			}
		} else if (entityId.getSObjectType() == Contact.getSObjectType()) {
			List<EmrServerContactReference__c> contactReferences = [
				SELECT Id, Name, Contact__c, Identifier__c, CreatedDate, EmrServer__c, EmrServer__r.Name, LastSyncDateTime__c
				FROM EmrServerContactReference__c
				WHERE Contact__c = :entityId
			];
			for (EmrServerContactReference__c refRecord : contactReferences) {
				references.add(new EntityServerReference(refRecord));
			}
		}

		return references;
	}

	public class EntityServerReference implements Comparable {
		@AuraEnabled
		public String entityName { get; set; }
		@AuraEnabled
		public String entityId { get; set; }
		@AuraEnabled
		public String serverName { get; set; }
		@AuraEnabled
		public String serverId { get; set; }
		@AuraEnabled
		public String serverUrl { get; set; }
		@AuraEnabled
		public String reference { get; set; }
		@AuraEnabled
		public DateTime lastSync { get; set; }
		@AuraEnabled
		public Boolean isPrimary { get; set; }

		public EntityServerReference(
			String entityName,
			String entityId,
			String serverName,
			String serverId,
			String reference,
			DateTime lastSync,
			Boolean isPrimary
		) {
			this.entityName = entityName;
			this.entityId = entityId;
			this.serverName = serverName;
			this.serverId = serverId;
			this.serverUrl = '/' + this.serverId;
			this.reference = reference;
			this.lastSync = lastSync;
			this.isPrimary = isPrimary;
		}

		public EntityServerReference(EmrServerAccountReference__c referenceRecord) {
			this(
				'Account',
				referenceRecord.Account__c,
				referenceRecord.EmrServer__r.Name,
				referenceRecord.EmrServer__c,
				referenceRecord.Identifier__c,
				referenceRecord.LastSyncDateTime__c,
				referenceRecord.IsPrimary__c
			);
		}

		public EntityServerReference(EmrServerContactReference__c referenceRecord) {
			this(
				'Contact',
				referenceRecord.Contact__c,
				referenceRecord.EmrServer__r.Name,
				referenceRecord.EmrServer__c,
				referenceRecord.Identifier__c,
				referenceRecord.LastSyncDateTime__c,
				false
			);
		}

		public Integer compareTo(Object compareTo) {
			EntityServerReference compareToRef = (EntityServerReference) compareTo;
			if (this.reference != null && compareToRef.reference == null) {
				return -1;
			} else if (this.reference == null && compareToRef.reference != null) {
				return 1;
			}
			return 0;
		}
	}
}
