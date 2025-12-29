/**
 * @description  : This class is responsible for processing Locations data from the Artemis EMR system.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisDataProcessors
 **/
public inherited sharing class ArtemisLocationsDataProcessor extends EmrServerAbstractDataProcessor {
	public ArtemisLocationsDataProcessor() {
		super();
	}

	Object prepare(Map<EmrServer, List<EmrRestClient.RestModel>> payloadsByServer, List<EmrServer> servers, List<EmrRestClient.RestModel> payloads) {
		Set<String> locationIds = Collection.of(payloads).collect(new LocationIdMapper()).getSetString();
		Set<Id> emrServerIds = Collection.of(servers).collect(new EmrServerIdMapper()).getSetId();

		List<Account> existingLocations = new LocationQuery().byEmrServerId(emrServerIds).byExternalId(locationIds).getList();
		Map<String, Account> locationsByServerAndKey = (Map<String, Account>) Collection.of(
				new LocationQuery().byEmrServerId(emrServerIds).byExternalId(locationIds).getList()
			)
			.mapByConcatenation(Account.LocationEmrServer__c, Account.LocationArtemisExternalId__c);

		LocationPreparedData result = new LocationPreparedData();
		result.existingLocationsByServerAndKey = locationsByServerAndKey;
		return result;
	}

	void handle(EmrRestClient.RestModel payload, EmrServerDataProcessRequestContext context) {
		LocationPreparedData preparedData = (LocationPreparedData) context.preparedData;
		ArtemisLocationRestModel locationPayload = (ArtemisLocationRestModel) payload;

		String sourceEmrServerId = context.sourceServer.emrServerId;
		String locationId = locationPayload.id;

		Account existingLocationRecord = preparedData.existingLocationsByServerAndKey.get(sourceEmrServerId + '' + locationId);

		DatabaseService databaseService = new DatabaseService().asSystemWithoutSharing();
		if (existingLocationRecord == null) {
			Account location = locationPayload.toSObject();
			location.LocationArtemisExternalId__c = locationPayload.id;
			location.LocationEmrServer__c = context.sourceServer.emrServerId;
			location.LocationBrand__c = context.sourceServer.emrServerRecord.NewLocationDefaultBrand__c;
			location.ParentId = context.sourceServer.emrServerRecord.NewLocationDefaultParentAccount__c;

			databaseService.insertRecord(location);
		} else {
			Account location = locationPayload.toSObject(existingLocationRecord.Id);

			databaseService.updateRecord(location);
		}
	}

	private class LocationPreparedData {
		public Map<String, Account> existingLocationsByServerAndKey { get; set; }
	}

	private class LocationIdMapper implements Collection.Mapper {
		public Object value(Object item) {
			return ((ArtemisLocationRestModel) item).id;
		}

		public Type valueType() {
			return String.class;
		}
	}
}
