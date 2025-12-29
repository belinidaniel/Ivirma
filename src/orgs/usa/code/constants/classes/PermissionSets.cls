/**
 * @description  : Constants for Permission Sets
 * @author       : Ivo Rocha
 **/
public class PermissionSets {
	public static PermissionSet MANAGE_PATIENTS {
		get {
			return resolve('ManagePatients');
		}
	}

	private static Map<String, PermissionSet> PERMISSIONSET_CACHE;
	private static PermissionSet resolve(String name) {
		// lazy evaluation
		if (PERMISSIONSET_CACHE == null) {
			PERMISSIONSET_CACHE = new Map<String, PermissionSet>();
			for (PermissionSet permissionSet : [SELECT Id, Name FROM PermissionSet]) {
				PERMISSIONSET_CACHE.put(permissionSet.Name, permissionSet);
			}
		}
		return PERMISSIONSET_CACHE.get(name);
	}

	private PermissionSets() {
	}
}
