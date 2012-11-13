/**
 * Representation of a server response
 */
package dit.upm.es.ging.vishmobile.core;

import org.json.JSONObject;


/**
 * @author Daniel Gallego Vico
 *
 */
public class ServerResponse {
	
	private int responseCode;
	private JSONObject responseResult;
	
	/**
	 * Empty constructor
	 */
	public ServerResponse() {
		
	}
	
	/**
	 * Constructor 
	 * 
	 * @param responseCode
	 * @param responseResult
	 */
	public ServerResponse(int responseCode, JSONObject responseResult) {
		this.responseCode = responseCode;
		this.responseResult = responseResult;
	}

	public int getResponseCode() {
		return responseCode;
	}

	public void setResponseCode(int responseCode) {
		this.responseCode = responseCode;
	}

	public JSONObject getResponseResult() {
		return responseResult;
	}

	public void setResponseResult(JSONObject responseResult) {
		this.responseResult = responseResult;
	}

	
}