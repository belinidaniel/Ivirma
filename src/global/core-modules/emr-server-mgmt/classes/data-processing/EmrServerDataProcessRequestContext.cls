/**
 * @description  : Class to hold the information of the request context to be processed by the abstract class.
 * @author       : Ivo Rocha
 * @testSuites   : EMRServerMgmt
 **/
public class EmrServerDataProcessRequestContext {
	public EmrServer sourceServer { get; private set; }
	public Object preparedData { get; private set; }
	public Object additional { get; private set; }

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequestContext class.
	 * @param server : The source server.
	 * @param data : The prepared data.
	 */
	public EmrServerDataProcessRequestContext(EmrServer server, Object data) {
		this(server, data, null);
	}

	/**
	 * @description  : Constructor for the EmrServerDataProcessRequestContext class.
	 * @param server : The source server.
	 * @param data : The prepared data.
	 * @param additional : Additional context for the request.
	 */
	public EmrServerDataProcessRequestContext(EmrServer server, Object data, Object additional) {
		this.sourceServer = server;
		this.preparedData = data;
		this.additional = additional;
	}
}
