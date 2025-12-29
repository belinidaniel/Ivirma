/**
 * @description  : This class implements the metadata client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisMetadataClientImpl extends EmrRestClient.ClientImpl {
	public ArtemisMetadataClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : This method retrieves a list of all insurance companies metadata.
	 * @return       : List<ArtemisMetadataInsuranceCompanyRestModel>
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public List<ArtemisMetadataInsuranceCompanyRestModel> getInsuranceCompanies() {
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/metadata/insurance_company/list');
		callout.setResponseType(List<ArtemisMetadataInsuranceCompanyRestModel>.class);

		return (List<ArtemisMetadataInsuranceCompanyRestModel>) callout.execute();
	}

	/**
	 * @description  : This method retrieves a list of all referral sources metadata.
	 * @return       : List<ArtemisMetadataReferralSourceRestModel>
	 * @throws       : ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public List<ArtemisMetadataReferralSourceRestModel> getReferralSources() {
		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/metadata/referral_source/list');
		callout.setResponseType(List<ArtemisMetadataReferralSourceRestModel>.class);

		return (List<ArtemisMetadataReferralSourceRestModel>) callout.execute();
	}
}
