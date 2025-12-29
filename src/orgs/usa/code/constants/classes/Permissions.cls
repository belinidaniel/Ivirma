/**
 * @description  : Constants for Custom Permissions
 * @author       : Ivo Rocha
 **/
public class Permissions {
	public static Boolean SyncProviders {
		get {
			return resolve('SyncProviders');
		}
	}

	private static Boolean resolve(String customPermission) {
		return FeatureManagement.checkPermission(customPermission);
	}

	private Permissions() {
	}
}
