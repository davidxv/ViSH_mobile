/**
 * Data model to store useful information
 */
package dit.upm.es.ging.vishmobile.core;

import android.app.Activity;
import android.content.SharedPreferences;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class Model {
	
	//Constants
	private static final String PREFS_NAME = "ViSH Mobile";
	private static final String PREFS_AUTH_TOKEN = "mAuthenticationToken";
	private static final String PREFS_USER_NAME = "mUserName";
	
	//Prevent Model to be initialized several times
	private static boolean initialized = false;
	
	
	// Stores the authentication token to be used in every call to the API.
	// It is only set when the user is logged in (the token has been tested against the server)
	private static String mAuthenticationToken;
	//Stores the user name
	private static String mUserName;

	
	public static void init(Activity activity){
		if(!initialized){
			SharedPreferences settings = activity.getSharedPreferences(PREFS_NAME, 0);
			String authenticationToken = settings.getString(PREFS_AUTH_TOKEN, null);
			String userName = settings.getString(PREFS_USER_NAME, null);
			Model.mAuthenticationToken = authenticationToken;
			Model.mUserName = userName;
			initialized = true;
		}
	}
	
	public static String getAuthenticationToken() {
		return mAuthenticationToken;
	}
	
	public static void setAuthenticationToken(Activity activity, String authenticationToken) {
		Model.mAuthenticationToken = authenticationToken;
		SharedPreferences settings = activity.getSharedPreferences(PREFS_NAME, 0);
		SharedPreferences.Editor editor = settings.edit();
	    editor.putString(PREFS_AUTH_TOKEN, authenticationToken);
	    editor.commit();
	}

	public static String getUserName() {
		return mUserName;
	}

	public static void setUserName(Activity activity,String userName) {
		Model.mUserName = userName;
		SharedPreferences settings = activity.getSharedPreferences(PREFS_NAME, 0);
		SharedPreferences.Editor editor = settings.edit();
	    editor.putString(PREFS_USER_NAME, userName);
	    editor.commit();
	}
	
}
