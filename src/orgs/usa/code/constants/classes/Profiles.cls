/**
 * @description  : Constants for Profiles
 * @author       : Ivo Rocha
 **/
public class Profiles {
	public static Profile SYSTEM_ADMINISTRATOR {
		get {
			return resolve('System Administrator');
		}
	}

	private static Map<String, Profile> PROFILES_CACHE;
	private static Profile resolve(String name) {
		// lazy evaluation
		if (PROFILES_CACHE == null) {
			PROFILES_CACHE = new Map<String, Profile>();
			for (Profile profile : [SELECT Id, Name FROM Profile]) {
				PROFILES_CACHE.put(profile.Name, profile);
			}
		}
		return PROFILES_CACHE.get(name);
	}

	private Profiles() {
	}
}
