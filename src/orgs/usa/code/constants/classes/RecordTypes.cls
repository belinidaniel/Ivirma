/**
 * @description  : Constants for Record Types
 * @author       : Ivo Rocha
 **/
public class RecordTypes {
	public static RecordTypeData ACCOUNT_PATIENT {
		get {
			return resolve(Account.SObjectType, 'PatientAccount');
		}
	}

	public static RecordTypeData ACCOUNT_BUSINESS {
		get {
			return resolve(Account.SObjectType, 'BusinessAccount');
		}
	}

	public static RecordTypeData ACCOUNT_LOCATION {
		get {
			return resolve(Account.SObjectType, 'LocationAccount');
		}
	}

	public static RecordTypeData CONTACT_PROVIDER {
		get {
			return resolve(Contact.SObjectType, 'Provider');
		}
	}

	public static RecordTypeData CONTACT_STAFF {
		get {
			return resolve(Contact.SObjectType, 'Staff');
		}
	}

	private static Map<SObjectType, Map<String, RecordTypeData>> recordTypeCache = new Map<SObjectType, Map<String, RecordTypeData>>();

	/**
	 * @description Resolves Record Type Data for given SObjectType and developerName by caching the results for that SObjectType if not already cached
	 * @param sObjectType The SObjectType to resolve the Record Type Data for
	 * @param developerName The developerName of the Record Type to resolve
	 * @return RecordTypeData The Record Type Data for the given SObjectType and developerName
	 */
	private static RecordTypeData resolve(SObjectType sObjectType, String developerName) {
		if (!recordTypeCache.containsKey(sObjectType)) {
			Map<String, RecordTypeInfo> recordTypeInfosByDevName = sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
			Map<String, RecordTypeData> recordTypeDataByDevName = new Map<String, RecordTypeData>();

			for (RecordTypeInfo recordTypeInfo : recordTypeInfosByDevName.values()) {
				RecordTypeData rtData = new RecordTypeData(recordTypeInfo);
				recordTypeDataByDevName.put(rtData.DeveloperName, rtData);
			}

			recordTypeCache.put(sObjectType, recordTypeDataByDevName);
		}

		return recordTypeCache.get(sObjectType).get(developerName);
	}

	private RecordTypes() {
	}
}
