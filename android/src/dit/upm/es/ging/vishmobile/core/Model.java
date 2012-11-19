/**
 * Data model to store useful information
 */
package dit.upm.es.ging.vishmobile.core;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class Model {
	
	// Stores the authentication token to be used in every call to the API.
	// It is only set when the user is logged in (the token has been tested against the server)
	private static String mAuthenticationToken;
	//Stores the user name
	private static String userName;
	
	public static String getAuthenticationToken() {
		return mAuthenticationToken;
	}
	
	public static void setAuthenticationToken(String authenticationToken) {
		Model.mAuthenticationToken = authenticationToken;
	}

	public static String getUserName() {
		return userName;
	}

	public static void setUserName(String userName) {
		Model.userName = userName;
	}
	
}
