/**
 * Constants used in the applications 
 */
package dit.upm.es.ging.vishmobile.core;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class Constants {
	
	public static final boolean VISH_LOCAL = false; //False to use VISH_TEST
	public static final boolean VISH_PRODUCTION = false; //True to use production version
	
	public static final String SERVER_URI_PRODUCTION = "http://vishub.global.dit.upm.es/";
	public static final String SERVER_URI_TEST = "http://vishub-test.global.dit.upm.es/";
	public static final String USER_INFO_PATH = "home.json";
	public static final String DOCUMENTS_PATH = "documents.json";
	public static final String SIGN_UP_PATH = "users/sign_up";
	
	public static final String FORMAT_HTML = "text/html";
	public static final String FORMAT_JSON = "application/json";
	public static final String FORMAT_UNKNOWN = "unknown";
	
	//Developping
	public static final String DEV_SERVER_URI = "http://138.4.4.164:3000/";
	public static final String AUTH_TOKEN_TEST = "Basic ZGVtb0Bzb2NpYWwtc3RyZWFtLmRpdC51cG0uZXM6ZGVtb25zdHJhdGlvbg==";
	public static final String PATH_IMAGE_TEST = "/mnt/sdcard/Pictures/VishPictures/test.jpg";
	
	public static String getServerURI(){
		if(VISH_PRODUCTION){
			return SERVER_URI_PRODUCTION;
		} else {
			if(VISH_LOCAL){
				return DEV_SERVER_URI;
			} else {
				return SERVER_URI_TEST;
			}
		}

	}
	
}
