/**
 * Utilities related to communications
 */
package dit.upm.es.ging.vishmobile.core;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Base64;


/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class CommunicationUtils {
	
	/**
	 * Check the Network Connection 
	 * 
	 * @param context
	 * @return true is the device is connected to the network, false if not
	 */
	public static boolean networkConnectionAvailable(Context context) {
		ConnectivityManager connMgr = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
		if (networkInfo != null && networkInfo.isConnected()) {
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Reads an InputStream
	 * 
	 * @param inStream
	 * @return a String representation of the result InputStream
	 */
	public static String readStream(InputStream inStream) {
		BufferedReader r = new BufferedReader(new InputStreamReader(inStream));
		StringBuilder total = new StringBuilder();
		String line;
		try {
			while ((line = r.readLine()) != null) {
			    total.append(line);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return total.toString();
	}
	
	/**
	 * Generates the authentication token given a username and a password.
	 * The generated token have to be used in every call to the API as 'Authorization' header.
	 * 
	 * The Authorization String is the BASE64_ENCODE of {username}:{password}.
	 * Before the {username}:{password} string is encoded in Base64, 
	 * it is converted to a UTF-16 (16-bit Unicode Transformation Format),
	 * using the little-endian 2 bytes per character representation. 
	 * This allows international characters to be used within usernames and passwords. 
	 * 
	 * @param username
	 * @param password
	 * @return generated authentication token
	 * @throws UnsupportedEncodingException on base64 encoding exception
	 */
	public static String generateAuthenticationTokenFromUserPassword(String username, String password) throws UnsupportedEncodingException {
		String authString = username + ":" + password;
        // On Android, the default charset is UTF-8.
		// NO_WRAP means that the Base64 encoder uses a flag bit to omit all line terminators (i.e., the output will be on one long line)
		// It's necessary to work in Android versions below 4.0
        return "Basic " + new String(Base64.encode(authString.getBytes(), Base64.NO_WRAP));
	}
	
	
	
	/**
	 * Returns a specific content type (HTML,JSON,...) of a server response
	 * @param contentType The MIME Type of the content specified by the response header field content
	 * @return specific content type
	 */
	public static String getContentType(String contentType){
		if(contentType.contains("text/html")){
			return Constants.FORMAT_HTML;
		} else if(contentType.contains("application/json")){
			return Constants.FORMAT_JSON;
		}
		return Constants.FORMAT_UNKNOWN;
	}
	
	/**
	 * Returns if a HTTP response code is an HTTP error code (4xx or 5xx).
	 * @param responseCode
	 * @return
	 */
	public static boolean isErrorResponseCode(int responseCode){
		 //TODO Apply regex to detect if responseCode starts with 4 or 5
		if(responseCode==HttpURLConnection.HTTP_UNAUTHORIZED){
			return true;
		}
		return false;
	}

}
