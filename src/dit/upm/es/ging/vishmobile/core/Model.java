/**
 * Data model to store useful information
 */
package dit.upm.es.ging.vishmobile.core;

/**
 * @author Daniel Gallego Vico
 *
 */
public class Model {
	
	// Stores the authentication token to be used in every call to the API.
	// It is only set when the user is logged in (the token has been tested against the server)
	private static String mAuthenticationToken;
	
	public static void setAuthenticationToken(String authenticationToken) {
		mAuthenticationToken = authenticationToken;
	}
	
	public static String getAuthenticationToken() {
		return mAuthenticationToken;
	}

}
