/**
 * @description  : Allows to search for availabilities in a given Artemis server from Flows
 * @author       : Ivo Rocha
 * @testSuite    :
 * @testClass    :
 **/
public with sharing class FlowAction_ArtemisAvailabilitiesSearch {
	/**
	 * @description  : Search for availabilities in Artemis
	 * @param        : List<FlowAction_ArtemisAvailabilitiesSearchRequest> requests
	 * @return       : List<List<ArtemisAvailabilityRestModel>>
	 */
	@InvocableMethod(
		label='Search for availabilities in Artemis'
		description='Search for availabilities in Artemis'
		category='Artemis REST Client'
		iconName='slds:standard:invocable_action'
	)
	public static List<List<ArtemisAvailabilityRestModel>> searchAvailabilities(List<FlowAction_ArtemisAvailabilitiesSearchRequest> requests) {
		List<List<ArtemisAvailabilityRestModel>> availabilitiesPerRequest = new List<List<ArtemisAvailabilityRestModel>>();

		Set<String> allProviderIds = new Set<String>();
		Set<String> allLocationIds = new Set<String>();
		Set<Id> emrServerIds = new Set<Id>();
		for (FlowAction_ArtemisAvailabilitiesSearchRequest request : requests) {
			emrServerIds.add(request.emrServerId);

			ArtemisRestClient restClient = (ArtemisRestClient) EmrRestClientFactory.getRestClientInstance(request.emrServerId);

			Date fromDate = request.fromDate != null ? request.fromDate : Date.today();
			Date toDate = request.toDate != null ? request.toDate : fromDate.addDays(7);
			List<String> locationIds = request.locationIds != null ? request.locationIds.split(';') : null;
			List<String> providerIds = request.providerIds != null ? request.providerIds.split(';') : null;

			// We need to enhance the response with additional information about the provider and location of the availability.
			// For this, lets collect the provider and location ids from the response so we can later fetch the related records.
			List<ArtemisAvailabilityRestModel> availabilities = restClient.availabilities.searchAvailabilities(
				request.appointmentType,
				fromDate,
				toDate,
				locationIds,
				providerIds
			);
			for (ArtemisAvailabilityRestModel availability : availabilities) {
				allProviderIds.add(availability.providerId);
				allLocationIds.add(availability.locationId);
				availability.internalContext.put('sourceEmrServerId', request.emrServerId);
			}
			availabilitiesPerRequest.add(availabilities);
		}

		Map<String, EmrServerContactReference__c> ermProviderReferencesByServerAndKey = (Map<String, EmrServerContactReference__c>) Collection.of(
				new EmrServerContactReferenceQuery().byEmrServerId(emrServerIds).byIdentifier(allProviderIds).getList()
			)
			.mapByConcatenation(EmrServerContactReference__c.EmrServer__c, EmrServerContactReference__c.Identifier__c);

		Map<Id, Contact> existingProvidersById = (Map<Id, Contact>) new ProviderQuery()
			.withErmServerReference(ermProviderReferencesByServerAndKey.values())
			.getMapById();

		Map<String, Account> existingLocationsByServerAndKey = (Map<String, Account>) Collection.of(
				new LocationQuery().byEmrServerId(emrServerIds).byExternalId(allLocationIds).getList()
			)
			.mapByConcatenation(Account.LocationEmrServer__c, Account.LocationArtemisExternalId__c);

		// Now that we have the provider and location ids, we can enhance the response with the related records information.
		for (List<ArtemisAvailabilityRestModel> availabilities : availabilitiesPerRequest) {
			for (ArtemisAvailabilityRestModel availability : availabilities) {
				EmrServerContactReference__c ermProviderReference = ermProviderReferencesByServerAndKey.get(
					availability.internalContext.get('sourceEmrServerId') + '' + availability.providerId
				);
				availability.internalContext.put('provider', ermProviderReference != null ? existingProvidersById.get(ermProviderReference.Contact__c) : null);
				availability.internalContext.put(
					'location',
					existingLocationsByServerAndKey.get(availability.internalContext.get('sourceEmrServerId') + '' + availability.locationId)
				);
			}
		}

		return availabilitiesPerRequest;
	}

	public class FlowAction_ArtemisAvailabilitiesSearchRequest {
		@InvocableVariable(label='Artemis Server Id' description='Artemis Server Id' required=true)
		public String emrServerId;

		@InvocableVariable(label='Appointment Type' description='Appointment Type' required=true)
		public String appointmentType;

		@InvocableVariable(label='Location Artemis Ids separated by semicolon' description='Location Artemis Ids separated by semicolon' required=false)
		public String locationIds;

		@InvocableVariable(label='Provider Artemis Ids separated by semicolon' description='Provider Artemis Ids separated by semicolon' required=false)
		public String providerIds;

		@InvocableVariable(label='From Date' description='Defaults to today if left empty' required=false)
		public Date fromDate;

		@InvocableVariable(label='To Date' description='Defaults to 7 days from \'From Date\' if left empty' required=false)
		public Date toDate;
	}
}
