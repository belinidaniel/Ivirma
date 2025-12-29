/**
 * @description  : This class represents an error response from the Artemis Rest API.
 * @author       : Ivo Rocha
 **/
public class ArtemisErrorResponseRestModel extends EmrRestClient.RestModel {
	public ArtemisErrorResponseErrorAttrRestModel error { get; private set; }
	public String status { get; private set; }
	public String timestamp { get; private set; }

	public ArtemisErrorResponseRestModel(String status, String errorCode, String errorMessage) {
		super();
		this.status = status;
		this.error = new ArtemisErrorResponseErrorAttrRestModel(errorCode, errorMessage);
		this.timestamp = String.valueOf(DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
	}

	public Boolean isProperlyDefined() {
		return status != null && timestamp != null && error != null;
	}

	public class ArtemisErrorResponseErrorAttrRestModel {
		public String code { get; set; }
		public String message { get; set; }

		public ArtemisErrorResponseErrorAttrRestModel(String code, String message) {
			this.code = code;
			this.message = message;
		}
	}
}
