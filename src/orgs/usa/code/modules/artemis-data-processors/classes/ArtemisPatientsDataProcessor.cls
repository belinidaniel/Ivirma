/**
 * @description  : This class is responsible for processing Patients data from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisPatientsDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisPatientsDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();

		// Get existing patients
		Set<String> patientIds = Collection.of(payloads).collect(new PatientIdMapper()).getSetString();
		Map<String, PatientServerProfile__c> existingPatientServerProfilesByServerAndKey = (Map<String, PatientServerProfile__c>) Collection.of(
				new PatientServerProfileQuery().byEmrServerId(emrServerIds).byExternalId(patientIds).getList()
			)
			.mapByConcatenation(PatientServerProfile__c.EmrServer__c, PatientServerProfile__c.ArtemisPatientId__c);

		// Get existing locations referenced in the patient payloads
		Set<String> locationIds = Collection.of(payloads).collect(new PatientPrimaryLocationIdMapper()).getSetString();
		locationIds.remove(null); // Remove null id values, if any.
		Map<String, Account> existingLocationsByServerAndKey = (Map<String, Account>) Collection.of(
				new LocationQuery().byEmrServerId(emrServerIds).byExternalId(locationIds).getList()
			)
			.mapByConcatenation(Account.LocationEmrServer__c, Account.LocationArtemisExternalId__c);

		// Get existing providers referenced in the patient payloads
		Set<String> doctorIds = Collection.of(payloads).collect(new PatientPrimaryDoctorIdMapper()).getSetString();
		doctorIds.remove(null); // Remove null id values, if any.
		Map<String, EmrServerContactReference__c> ermDoctorReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byIdentifier(doctorIds).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Identifier__c);

		// Get existing referral sources referenced in the patient payloads
		List<ArtemisPatientReferralSourceRestModel> allPatientsReferralSources = (List<ArtemisPatientReferralSourceRestModel>) Collection.of(payloads)
			.reduce(new ReferralSourceMetadataReducer(), new List<ArtemisPatientReferralSourceRestModel>());
		Set<String> referralSourcePractitionerIds = Collection.of(allPatientsReferralSources).collect(new ReferralSourcePractitionerIdMapper()).getSetString();
		referralSourcePractitionerIds.remove(null); // Remove null id values, if any.
		Map<String, EmrServerContactReference__c> ermReferralPractitionerReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery()
					.byEmrServerId(emrServerIds)
					.byField(EmrServerContactReference__c.ArtemisReferralSourceIdentifier__c, 'IN', referralSourcePractitionerIds)
					.getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.ArtemisReferralSourceIdentifier__c);

		// Get ALL existing insurance companies in the system, for the given EMR servers (TODO: filtering for optimization?)
		Map<String, EmrServerInsuranceCompanyMetadata__c> allErmInsuranceCompanyMetadataByServerAndKey = (Map<String, EmrServerInsuranceCompanyMetadata__c>) Collection.of(
				new EmrServerInsuranceCompanyMetadataQuery().byEmrServerId(emrServerIds).getList()
			)
			.mapByConcatenation(EmrServerInsuranceCompanyMetadata__c.EmrServer__c, EmrServerInsuranceCompanyMetadata__c.InsuranceCompanyInternalId__c);

		//TODO: missing business rule logic for when patient profile will not be found, but a Patient record might exist - what should be the rules to find that Patient record?

		PatientPreparedData result = new PatientPreparedData();
		result.existingPatientServerProfilesByServerAndKey = existingPatientServerProfilesByServerAndKey;
		result.existingLocationsByServerAndKey = existingLocationsByServerAndKey;
		result.ermDoctorReferencesByServerAndKey = ermDoctorReferencesByServerAndKey;
		result.ermReferralPractitionerReferencesByServerAndKey = ermReferralPractitionerReferencesByServerAndKey;
		result.allErmInsuranceCompanyMetadataByServerAndKey = allErmInsuranceCompanyMetadataByServerAndKey;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();

		PatientPreparedData preparedData = (PatientPreparedData) context.preparedData;
		ArtemisPatientRestModel patientPayload = (ArtemisPatientRestModel) payload;

		String sourceEmrServerId = context.sourceServer.emrServerId;
		String patientId = patientPayload.id;

		PatientServerProfile__c existingPatientServerProfile = preparedData.existingPatientServerProfilesByServerAndKey.get(sourceEmrServerId + '' + patientId);
		Id targetPatientAccountId = existingPatientServerProfile?.PatientAccount__c;

		if (existingPatientServerProfile == null) {
			// Lets try to find a matching Account patient record in the database
			Account matchingPatientAccount = findMatchingPatientAccountRecord(patientPayload);
			if (matchingPatientAccount != null) {
				targetPatientAccountId = matchingPatientAccount.Id;
			} else {
				//TODO: should we instead just create a new Patient Account record?
				Account newPatientAccount = new Account();
				newPatientAccount.FirstName = patientPayload.firstName;
				newPatientAccount.LastName = patientPayload.lastName;
				newPatientAccount.PersonEmail = patientPayload.email;
				newPatientAccount.PersonBirthdate = patientPayload.dateOfBirth;
				databaseService.insertRecord(newPatientAccount);

				targetPatientAccountId = newPatientAccount.Id;
				// throw new EmrServerDataProcessException(
				// 	'No existing matching Patient Account was found for patient ' +
				// 		patientId +
				// 		' with server ' +
				// 		sourceEmrServerId +
				// 		'. Integration of patient data will not proceed.'
				// );
			}
		}

		ArtemisPatientRestModel.ToSObjectContextRefs contextRefs = new ArtemisPatientRestModel.ToSObjectContextRefs();

		if (patientPayload.primaryInsurance != null) {
			contextRefs.sfPrimaryInsuranceCompanyMetadataId = preparedData.allErmInsuranceCompanyMetadataByServerAndKey.get(
					sourceEmrServerId + '' + patientPayload.primaryInsurance.insuranceCompanyId
				)
				?.Id;
		}

		if (patientPayload.secondaryInsurance != null) {
			contextRefs.sfSecondaryInsuranceCompanyMetadataId = preparedData.allErmInsuranceCompanyMetadataByServerAndKey.get(
					sourceEmrServerId + '' + patientPayload.secondaryInsurance.insuranceCompanyId
				)
				?.Id;
		}

		if (patientPayload.tertiaryInsurance != null) {
			contextRefs.sfTertiaryInsuranceCompanyMetadataId = preparedData.allErmInsuranceCompanyMetadataByServerAndKey.get(
					sourceEmrServerId + '' + patientPayload.tertiaryInsurance.insuranceCompanyId
				)
				?.Id;
		}

		if (patientPayload.primaryLocationId != null) {
			contextRefs.sfPrimaryLocationId = preparedData.existingLocationsByServerAndKey.get(sourceEmrServerId + '' + patientPayload.primaryLocationId)?.Id;
		}

		if (patientPayload.primaryDoctorId != null) {
			contextRefs.sfPrimaryDoctorId = preparedData.ermDoctorReferencesByServerAndKey.get(sourceEmrServerId + '' + patientPayload.primaryDoctorId)
				?.Contact__c;
		}

		PatientServerProfile__c processedPatientServerProfile = patientPayload.toSObject(existingPatientServerProfile?.Id, contextRefs);
		if (existingPatientServerProfile == null) {
			// These fields are Master Details and can only be populated when creating new record
			processedPatientServerProfile.EmrServer__c = context.sourceServer.emrServerId;
			processedPatientServerProfile.PatientAccount__c = targetPatientAccountId;
		}
		processedPatientServerProfile.LastSyncDateTime__c = System.now();

		//TODO handle Referral Sources

		databaseService.upsertRecord(processedPatientServerProfile, PatientServerProfile__c.Id);
	}

	/**
	 * @description  : Try to find a matching Account record for the given patient payload.
	 * @param        : ArtemisPatientRestModel patientPayload
	 * @return       : Account record, if found, otherwise null.
	 */
	private static Account findMatchingPatientAccountRecord(ArtemisPatientRestModel patientPayload) {
		// Try to find a matching patient account record through patient server profiles records
		Id potentialPatientAccountId = findMatchingPatientAccountRecordThroughPatientServerProfiles(patientPayload);
		if (potentialPatientAccountId != null) {
			return (Account) new PatientQuery().byId(potentialPatientAccountId).getFirstOrNull();
		}

		// If no patient server profile was found, try to find a matching patient account record through patient Account fields
		PatientQuery patientQuery = new PatientQuery();

		List<String> emails = new List<String>();
		if (String.isNotBlank(patientPayload.email)) {
			emails.add(patientPayload.email);
		}
		if (String.isNotBlank(patientPayload.additionalEmail)) {
			emails.add(patientPayload.additionalEmail);
		}

		List<String> filterLogic = new List<String>();
		Map<String, Object> filterParameters = new Map<String, Object>();
		// by SSN if provided
		if (String.isNotBlank(patientPayload.socialSecurityNumber)) {
			List<String> logic = new List<String>();

			logic.add(Account.SocialSecurityNumber__pc + ' = :socialSecurityNumber');
			filterParameters.put('socialSecurityNumber', patientPayload.socialSecurityNumber);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		// or by first name, last name and email
		if (String.isNotBlank(patientPayload.firstName) && String.isNotBlank(patientPayload.lastName) && !emails.isEmpty()) {
			List<String> logic = new List<String>();

			logic.add(Account.FirstName + ' = :firstName');
			filterParameters.put('firstName', patientPayload.firstName);

			logic.add(Account.LastName + ' = :lastName');
			filterParameters.put('lastName', patientPayload.lastName);

			logic.add(Account.PersonEmail + ' IN :emails');
			filterParameters.put('emails', emails);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		// or by last name, birthdate and email
		if (String.isNotBlank(patientPayload.lastName) && patientPayload.dateOfBirth != null && !emails.isEmpty()) {
			List<String> logic = new List<String>();

			logic.add(Account.LastName + ' = :lastName');
			filterParameters.put('lastName', patientPayload.lastName);

			logic.add(Account.PersonBirthdate + ' = :dateOfBirth');
			filterParameters.put('dateOfBirth', patientPayload.dateOfBirth);

			logic.add(Account.PersonEmail + ' IN :emails');
			filterParameters.put('emails', emails);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		if (!filterLogic.isEmpty()) {
			patientQuery.wheres('(' + String.join(filterLogic, ' OR ') + ')', filterParameters);
			//patientQuery.orderBy(Account.CreatedDate, QueryObject.SortOrder.DESCENDING);
			return (Account) patientQuery.getFirstOrNull();
		}

		return null;
	}

	/**
	 * @description  : This method is used to try to find a matching patient account record through patient server profiles records.
	 * @param        : ArtemisPatientRestModel patientPayload
	 * @return       : Id of the matching patient account record, if found, otherwise null.
	 */
	private static Id findMatchingPatientAccountRecordThroughPatientServerProfiles(ArtemisPatientRestModel patientPayload) {
		PatientServerProfileQuery patientServerProfileQuery = new PatientServerProfileQuery();

		List<String> filterLogic = new List<String>();
		Map<String, Object> filterParameters = new Map<String, Object>();

		List<String> emails = new List<String>();
		if (String.isNotBlank(patientPayload.email)) {
			emails.add(patientPayload.email);
		}
		if (String.isNotBlank(patientPayload.additionalEmail)) {
			emails.add(patientPayload.additionalEmail);
		}

		// by SSN if provided
		if (String.isNotBlank(patientPayload.socialSecurityNumber)) {
			List<String> logic = new List<String>();

			logic.add(PatientServerProfile__c.SocialSecurityNumber__c + ' = :socialSecurityNumber');
			filterParameters.put('socialSecurityNumber', patientPayload.socialSecurityNumber);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		// or by first name, last name and email
		if (String.isNotBlank(patientPayload.firstName) && String.isNotBlank(patientPayload.lastName) && !emails.isEmpty()) {
			List<String> logic = new List<String>();

			logic.add(PatientServerProfile__c.FirstName__c + ' = :firstName');
			filterParameters.put('firstName', patientPayload.firstName);

			logic.add(PatientServerProfile__c.LastName__c + ' = :lastName');
			filterParameters.put('lastName', patientPayload.lastName);

			logic.add(PatientServerProfile__c.Email__c + ' IN :emails');
			filterParameters.put('emails', emails);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		// or by last name, birthdate and email
		if (String.isNotBlank(patientPayload.lastName) && patientPayload.dateOfBirth != null && !emails.isEmpty()) {
			List<String> logic = new List<String>();

			logic.add(PatientServerProfile__c.LastName__c + ' = :lastName');
			filterParameters.put('lastName', patientPayload.lastName);

			logic.add(PatientServerProfile__c.BirthDate__c + ' = :dateOfBirth');
			filterParameters.put('dateOfBirth', patientPayload.dateOfBirth);

			logic.add(PatientServerProfile__c.Email__c + ' IN :emails');
			filterParameters.put('emails', emails);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		// or by first name, last name and phone
		if (
			String.isNotBlank(patientPayload.firstName) &&
			String.isNotBlank(patientPayload.lastName) &&
			patientPayload.phone != null &&
			String.isNotBlank(patientPayload.phone.phoneNumber)
		) {
			List<String> logic = new List<String>();

			logic.add(PatientServerProfile__c.FirstName__c + ' = :firstName');
			filterParameters.put('firstName', patientPayload.firstName);

			logic.add(PatientServerProfile__c.LastName__c + ' = :lastName');
			filterParameters.put('lastName', patientPayload.lastName);

			logic.add(PatientServerProfile__c.Phone__c + ' = :phone');
			filterParameters.put('phone', patientPayload.phone.phoneNumber);

			filterLogic.add('(' + String.join(logic, ' AND ') + ')');
		}

		if (!filterLogic.isEmpty()) {
			patientServerProfileQuery.wheres('(' + String.join(filterLogic, ' OR ') + ')', filterParameters);
			//patientServerProfileQuery.orderBy(PatientServerProfile__c.CreatedDate, QueryObject.SortOrder.DESCENDING);

			//TODO if multiple patient server profiles are found, what should be the rules to find the correct one?

			return ((PatientServerProfile__c) patientServerProfileQuery.getFirstOrNull())?.PatientAccount__c;
		}

		return null;
	}

	private class PatientPreparedData {
		public Map<String, PatientServerProfile__c> existingPatientServerProfilesByServerAndKey { get; set; }
		public Map<String, EmrServerContactReference__c> ermDoctorReferencesByServerAndKey { get; set; }
		public Map<String, Account> existingLocationsByServerAndKey { get; set; }
		public Map<String, EmrServerContactReference__c> ermReferralPractitionerReferencesByServerAndKey { get; set; }
		public Map<String, EmrServerInsuranceCompanyMetadata__c> allErmInsuranceCompanyMetadataByServerAndKey { get; set; }
	}

	private class PatientIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPatientRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class PatientPrimaryLocationIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPatientRestModel) item).primaryLocationId;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class PatientPrimaryDoctorIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPatientRestModel) item).primaryDoctorId;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class ReferralSourceMetadataReducer implements Collection.Reducer {
		public Object reduce(Object accumulator, Object item, Integer index) {
			List<ArtemisPatientReferralSourceRestModel> accumulatorList = (List<ArtemisPatientReferralSourceRestModel>) accumulator;
			List<ArtemisPatientReferralSourceRestModel> referralSources = ((ArtemisPatientRestModel) item).referralSources;

			if (referralSources != null && !referralSources.isEmpty()) {
				accumulatorList.addAll(referralSources);
			}

			return accumulatorList;
		}
	}

	private class ReferralSourceMetadataIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPatientReferralSourceRestModel) item).referralSourceMetadataId;
		}

		public Type valueType() {
			return String.class;
		}
	}

	private class ReferralSourcePractitionerIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisPatientReferralSourceRestModel) item).refByPractitionerId;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
