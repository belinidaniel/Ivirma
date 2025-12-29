/**
 * @description  : This class implements the patients client for the EMR Artemis Rest API
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisPatientsClientImpl extends EmrRestClient.ClientImpl implements EmrRestClient.IPatients {
	public ArtemisPatientsClientImpl(ArtemisRestClient client) {
		super(client);
	}

	/**
	 * @description  : Not implemented.
	 */
	public EmrRestClient.RestModel findPatient(Map<String, Object> filters) {
		throw new EmrRestClientException('ArtemisRestClientImpl.findPatient: This method is not implemented.');
	}

	/**
	 *	@description  : This method retrieves a patient by its ID.
	 *	@param patientId : The ID of the patient to retrieve.
	 *	@return : ArtemisPatientRestModel
	 *	@throws EmrRestClientException - If the patient ID is null or empty.
	 *	@throws ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisPatientRestModel getPatient(String patientId) {
		if (String.isBlank(patientId)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.getPatient: Patient ID cannot be null or empty.');
		}

		Callout callout = client.buildCallout();
		callout.setMethod('GET');
		callout.setEndpoint('/api/v1/patient/' + patientId);
		callout.setResponseType(ArtemisPatientRestModel.class);

		return (ArtemisPatientRestModel) callout.execute();
	}

	/**
	 * @description  : This method creates a new patient.
	 * @param patient : The patient to create.
	 * @return : ArtemisPatientRestModel - The created patient.
	 * @throws EmrRestClientException - If the patient is null.
	 * @throws ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisPatientRestModel createPatient(EmrRestClient.RestModel patient) {
		if (patient == null) {
			throw new EmrRestClientException('ArtemisRestClientImpl.createPatient: Patient cannot be null.');
		}

		ArtemisPatientRestModel artemisPatient = (ArtemisPatientRestModel) patient;

		Callout callout = client.buildCallout();
		callout.setMethod('POST');
		callout.setEndpoint('/api/v1/patient');
		callout.setBody(artemisPatient.serialize());
		callout.setResponseType(ArtemisPatientRestModel.class);

		return (ArtemisPatientRestModel) callout.execute();
	}

	/**
	 * @description  : This method updates an existing patient.
	 * @param patient : The patient to update.
	 * @return : ArtemisPatientRestModel - The updated patient.
	 * @throws EmrRestClientException - If the patient is null or if the patient ID is null or empty.
	 * @throws ArtemisRestClientApiErrorException - If the API returns an error.
	 */
	public ArtemisPatientRestModel updatePatient(EmrRestClient.RestModel patient) {
		if (patient == null) {
			throw new EmrRestClientException('ArtemisRestClientImpl.createPatient: Patient cannot be null.');
		}

		ArtemisPatientRestModel artemisPatient = (ArtemisPatientRestModel) patient;
		if (String.isBlank(artemisPatient.id)) {
			throw new EmrRestClientException('ArtemisRestClientImpl.updatePatient: Patient ID cannot be null or empty.');
		}

		Callout c = client.buildCallout();
		c.setMethod('PUT');
		c.setEndpoint('/api/v1/patient/' + artemisPatient.id);
		c.setBody(artemisPatient.serialize());
		c.setResponseType(ArtemisPatientRestModel.class);

		return (ArtemisPatientRestModel) c.execute();
	}
}
