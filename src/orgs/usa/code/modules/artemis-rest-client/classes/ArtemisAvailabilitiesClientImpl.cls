/**
 * @description  : This class implements the availabilities client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisAvailabilitiesClientImpl extends EmrRestClient.ClientImpl implements EmrRestClient.IAvailabilities {
	public ArtemisAvailabilitiesClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : Not implemented.
	 */
	public ArtemisAvailabilityRestModel getAvailability(String availabilityId) {
		throw new EmrRestClientException('ArtemisRestClientImpl.getAvailability: This method is not implemented.');
	}

	/**
	 * @description  : This method retrieves a list of availabilities based on the given filters.
	 * @param        : filters - A map of search parameters. Currently, only 'locationIds', 'providerIds', 'appointmentType', 'startDate', and 'endDate' are supported.
	 * 					- locationIds: A list of location IDs to filter by.
	 * 					- providerIds: A list of provider IDs to filter by.
	 * 					- appointmentType: The type of appointment to filter by.
	 * 					- fromDate: The start date for the availability search.
	 * 					- toDate: The end date for the availability search.
	 * @return       : List<ArtemisAvailabilityRestModel>
	 * @throws       : EmrRestClientException - If any required input parameter is invalid or missing
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error
	 */
	public List<ArtemisAvailabilityRestModel> searchAvailabilities(Map<String, Object> filters) {
		Map<String, String> params = new Map<String, String>();
		if (filters == null) {
			filters = new Map<String, Object>();
		}

		if (filters.containsKey('locationIds') && filters.get('locationIds') instanceof List<String>) {
			String locationIds = String.join((List<String>) filters.get('locationIds'), ',');
			if (String.isNotBlank(locationIds)) {
				params.put('locationIds', locationIds);
			}
		}

		if (filters.containsKey('providerIds') && filters.get('providerIds') instanceof List<String>) {
			String providerIds = String.join((List<String>) filters.get('providerIds'), ',');
			if (String.isNotBlank(providerIds)) {
				params.put('providerIds', providerIds);
			}
		}

		if (filters.containsKey('appointmentType')) {
			params.put('appointmentType', (String) filters.get('appointmentType'));
		}

		Date fromDate = null;
		if (filters.containsKey('fromDate') && filters.get('fromDate') instanceof Date) {
			fromDate = (Date) filters.get('fromDate');
			params.put('startDate', fromDate.year() + '-' + fromDate.month().toString().leftPad(2, '0') + '-' + fromDate.day().toString().leftPad(2, '0')); //TODO ask Artemis to rename startDate param to fromDate
		} else {
			fromDate = Date.today();
			params.put('startDate', fromDate.year() + '-' + fromDate.month().toString().leftPad(2, '0') + '-' + fromDate.day().toString().leftPad(2, '0')); //TODO ask Artemis to rename startDate param to fromDate
		}

		Date toDate = null;
		if (filters.containsKey('toDate') && filters.get('toDate') instanceof Date) {
			toDate = (Date) filters.get('toDate');
			params.put('endDate', toDate.year() + '-' + toDate.month().toString().leftPad(2, '0') + '-' + toDate.day().toString().leftPad(2, '0')); //TODO ask Artemis to rename endDate param to toDate
		} else {
			// Default to 7 days from startDate if no endDate is provided
			toDate = fromDate.addDays(7);
			params.put('endDate', toDate.year() + '-' + toDate.month().toString().leftPad(2, '0') + '-' + toDate.day().toString().leftPad(2, '0')); //TODO ask Artemis to rename endDate param to toDate
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/availability/search');
		callout.setParams(params, true);
		callout.setResponseType(List<ArtemisAvailabilityRestModel>.class);

		return (List<ArtemisAvailabilityRestModel>) callout.execute();
	}

	/**
	 * @description  : This method searches for availabilities based on the given parameters.
	 * @param        : appointmentType - The type of appointment to search for.
	 * @param        : fromDate - The start date for the availability search.
	 * @param        : toDate - The end date for the availability search.
	 * @param        : locationIds - A list of location IDs to filter by.
	 * @param        : providerIds - A list of provider IDs to filter by.
	 * @return       : List<ArtemisAvailabilityRestModel>
	 */
	public List<ArtemisAvailabilityRestModel> searchAvailabilities(
		String appointmentType,
		Date fromDate,
		Date toDate,
		List<String> locationIds,
		List<String> providerIds
	) {
		Map<String, Object> filters = new Map<String, Object>();
		filters.put('appointmentType', appointmentType);
		filters.put('fromDate', fromDate);
		filters.put('toDate', toDate);
		filters.put('locationIds', locationIds);
		filters.put('providerIds', providerIds);

		return searchAvailabilities(filters);
	}

	/**
	 * @description  : This method reserves an availability by its ID.
	 * @param        : availabilityId - The ID of the availability to reserve.
	 * @return       : EmrRestClient.RestModel - The response from the API - TODO
	 * @throws       : EmrRestClientException - If the availabilityId is null or empty.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisAvailabilityRestModel reserveAvailability(String availabilityId) {
		if (String.isBlank(availabilityId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.reserveAvailability: availabilityId is required.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('POST');
		callout.setEndpoint('/api/v1/availability/' + availabilityId + '/reserve');
		callout.setResponseType(ArtemisAvailabilityRestModel.class);

		return (ArtemisAvailabilityRestModel) callout.execute();
	}

	/**
	 * @description  : This method releases an availability by its ID.
	 * @param        : availabilityId - The ID of the availability to release.
	 * @return       : EmrRestClient.RestModel - The response from the API - TODO
	 * @throws       : EmrRestClientException - If the availabilityId is null or empty.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisAvailabilityRestModel releaseAvailability(String availabilityId) {
		if (String.isBlank(availabilityId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.reserveAvailability: availabilityId is required.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('POST');
		callout.setEndpoint('/api/v1/availability/' + availabilityId + '/release');
		callout.setResponseType(ArtemisAvailabilityRestModel.class);

		return (ArtemisAvailabilityRestModel) callout.execute();
	}
}
