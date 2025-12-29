/**
 * @description  : Class to hold the information of the request result processed by the abstract class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public class EmrServerDataProcessRequestResult {
	public Boolean success { get; private set; }
	public String message { get; private set; }
	public EmrServerDataProcessRequest context { get; private set; }

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequestResult class.
	 * @param success : Whether the request was successful.
	 * @param message : The message of the request.
	 */
	public EmrServerDataProcessRequestResult(Boolean success, String message) {
		this(success, message, null);
	}

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequestResult class.
	 * @param success : Whether the request was successful.
	 * @param message : The message of the request.
	 * @param context : The context of the request.
	 */
	public EmrServerDataProcessRequestResult(Boolean success, String message, EmrServerDataProcessRequest context) {
		this.success = success;
		this.message = message;
		this.context = context;
	}

	/**
	 * @description  : Whether the request was successful.
	 * @return : Whether the request was successful.
	 */
	public Boolean isSuccess() {
		return this.success;
	}

	/**
	 * @description  : The message of the request.
	 * @return : The message of the request.
	 */
	public String getMessage() {
		return this.message;
	}

	/**
	 * @description  : The context of the request.
	 * @return : The context of the request.
	 */
	public EmrServerDataProcessRequest getContext() {
		return this.context;
	}
}
