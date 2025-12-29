/**
 * @description  : Class to hold the information of the request to be processed by the abstract class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public class EmrServerDataProcessRequest {
	public EmrServer sourceServer { get; private set; }
	public EmrRestClient.RestModel payload { get; private set; }
	public Object additionalContext { get; private set; }

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequest class.
	 * @param sourceServer : The source server.
	 * @param payload : The payload to be processed.
	 */
	public EmrServerDataProcessRequest(EmrServer sourceServer, EmrRestClient.RestModel payload) {
		this.sourceServer = sourceServer;
		this.payload = payload;
	}

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequest class.
	 * @param sourceServer : The source server.
	 * @param payload : The payload to be processed.
	 * @param additionalContext : Any object. Additional context for the request.
	 */
	public EmrServerDataProcessRequest(EmrServer sourceServer, EmrRestClient.RestModel payload, Object additionalContext) {
		this.sourceServer = sourceServer;
		this.payload = payload;
		this.additionalContext = additionalContext;
	}
}
