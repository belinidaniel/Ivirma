/**
 * @description  : Query object for Location (Account) records.
 * @author       : Ivo Rocha
 **/
public inherited sharing class LocationQuery extends QueryObject {
	public LocationQuery() {
		super(
			new List<SObjectField>{
				Account.Id,
				Account.ParentId,
				Account.OwnerId,
				Account.RecordTypeId,
				Account.Name,
				Account.LocationEmrServer__c,
				Account.LocationArtemisExternalId__c,
				Account.LocationBrand__c,
				Account.Type,
				Account.RetiredBusiness__c,
				Account.LocationAddress__CountryCode__s,
				Account.LocationAddress__StateCode__s,
				Account.LocationAddress__City__s,
				Account.LocationAddress__Street__s,
				Account.LocationAddress__PostalCode__s,
				Account.Phone,
				Account.Fax
			},
			Account.SObjectType
		);
		byRecordTypeId(RecordTypes.ACCOUNT_LOCATION.Id);
	}

	public LocationQuery byEmrServerId(Id emrServerId) {
		return byEmrServerId(new Set<Id>{ emrServerId });
	}

	public LocationQuery byEmrServerId(Set<Id> emrServerIds) {
		return (LocationQuery) byField(Account.LocationEmrServer__c, 'IN', emrServerIds);
	}

	public LocationQuery byExternalId(String externalId) {
		return byExternalId(new Set<String>{ externalId });
	}

	public LocationQuery byExternalId(Set<String> externalIds) {
		return (LocationQuery) byField(Account.LocationArtemisExternalId__c, 'IN', externalIds);
	}

	public LocationQuery byBrand(String brand) {
		return byBrand(new Set<String>{ brand });
	}

	public LocationQuery byBrand(Set<String> brands) {
		return (LocationQuery) byField(Account.LocationBrand__c, 'IN', brands);
	}
}
