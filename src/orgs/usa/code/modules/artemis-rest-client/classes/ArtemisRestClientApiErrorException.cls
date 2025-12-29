/**
 * @description  : Exception class for handling error responses from the Artemis REST API.
 * @author       : Ivo Rocha
 * @testSuite	 : ArtemisRestClient
 **/
public class ArtemisRestClientApiErrorException extends Exception {
	public ArtemisErrorResponseRestModel response;

	public ArtemisRestClientApiErrorException(ArtemisErrorResponseRestModel response) {
		this.setMessage('Artemis API Error: ' + response?.status + ' - ' + response?.error?.message);
		this.response = response;
	}

	public ArtemisErrorResponseRestModel getResponse() {
		return this.response;
	}
}
