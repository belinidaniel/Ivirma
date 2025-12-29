/**
 * @description  : This class implements the practitioners client for the EMR Artemis Rest API.
 * @author       : Ivo Rocha
 * @testSuite    : ArtemisRestClient
 **/
public class ArtemisPractitionersClientImpl extends EmrRestClient.ClientImpl {
	public ArtemisPractitionersClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : This method retrieves a practitioner by its ID.
	 * @param        : practitionerId - The ID of the practitioner to retrieve.
	 * @return       : ArtemisPractitionerRestModel
	 * @throws       : EmrRestClientException - If the practitioner ID is null or empty.
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisPractitionerRestModel getPractitioner(String practitionerId) {
		if (String.isBlank(practitionerId)) {
			throw new EmrRestClientException('ArtemisPractitionersClientImpl.getPractitioner: Practitioner ID cannot be null or empty.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/practitioner/' + practitionerId);
		callout.setResponseType(ArtemisPractitionerRestModel.class);

		return (ArtemisPractitionerRestModel) callout.execute();
	}

	/**
	 * @description  : This method retrieves a list of all practitioners.
	 * @return       : List<ArtemisPractitionerRestModel>
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public List<ArtemisPractitionerRestModel> getPractitioners() {
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/practitioner/list');
		callout.setResponseType(List<ArtemisPractitionerRestModel>.class);

		return (List<ArtemisPractitionerRestModel>) callout.execute();
	}
}
