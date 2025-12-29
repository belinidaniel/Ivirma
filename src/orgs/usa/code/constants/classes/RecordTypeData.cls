/**
 * @description  : Replacement to RecordType class to expose values that are only available on RecordTypeInfo
 * @author       : Ivo Rocha
 **/

public class RecordTypeData {
	@AuraEnabled
	public final Boolean isActive;
	@AuraEnabled
	public final Boolean isAvailable;
	@AuraEnabled
	public final Boolean isDefault;
	@AuraEnabled
	public final Boolean isMaster;
	@AuraEnabled
	public final String developerName;
	@AuraEnabled
	public final String name;
	@AuraEnabled
	public final Id id;

	public RecordTypeData(RecordTypeInfo recordTypeInfo) {
		this.developerName = recordTypeInfo.getDeveloperName();
		this.id = recordTypeInfo.getRecordTypeId();
		this.isActive = recordTypeInfo.isActive();
		this.isAvailable = recordTypeInfo.isAvailable();
		this.isDefault = recordTypeInfo.isDefaultRecordTypeMapping();
		this.isMaster = recordTypeInfo.isMaster();
		this.name = recordTypeInfo.getName();
	}
}
