/**
 * Manages every call to the ViSH API and its result.
 */
package dit.upm.es.ging.vishmobile.core;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Base64;
import android.util.Log;


/**
 * @author Daniel Gallego Vico
 *
 */
public class CommunicationManager {
	
	// Classic Singleton implementation.
	private static CommunicationManager instance = null;
	
	/**
	 * Protected constructor avoids common instantiation from other packages
	 */
	private CommunicationManager() {
			
	}
	
	/**
	 * Singleton management
	 * @return instance of CommunicationManager
	 */
	public static CommunicationManager getInstance() {
      if(instance == null) {
         instance = new CommunicationManager();
      }
      return instance;
	}
	
	/* 
	 * ======================================== 
	 * 				API METHODS
	 * ======================================== 
	 */
	
	/**
	 * Checks the validity of a given authentication token.
	 * As there is no specific method in the API to check it,
	 * a request to /home is done to find out if the 
	 * authentication token given is valid
	 * 
	 * @param authenticationToken
	 * @return
	 */
	public ServerResponse checkAuthenticationTokenValidity(String authenticationToken) {
		ServerResponse response;
		
		if (authenticationToken.length() == 0) {
			// TODO Add better control of Base64 Encoding exception
			return null;
		} else {
			String uri = Constants.SERVER_URI + Constants.USER_INFO_PATH;
			response = getRequestAuthorizationBasic(uri, authenticationToken);
		}
		return response;
	}
	
	/**
	 * 
	 * @param file
	 * @param title
	 * @param description
	 * @return
	 */
	public ServerResponse uploadDocument(String file, String title, String description) {
		String uri = Constants.SERVER_URI + "/documents.json";
		String body = "";
		ServerResponse result = postRequest(uri, body);
		return result;
	}
	
	
	/* 
	 * ======================================== 
	 * 				HTTP REQUESTS 
	 * ======================================== 
	 */
	
	
	/**
	 * HTTP GET request
	 * *****************
	 * 
	 * @param uri
	 * @return
	 */
	private ServerResponse getRequest(String uri) {
		return this.getRequestAuthorizationBasic(uri, Model.getAuthenticationToken());
	}
	
	/**
	 * HTTP GET request (Authorization: Basic)
	 * ****************************************
	 * 
	 * @param uri
	 * @param authenticationToken
	 * @return
	 */
	private ServerResponse getRequestAuthorizationBasic(String uri, String authenticationToken) {
		
		// the string to store the response text from the server
        ServerResponse response = new ServerResponse();
        
		try {
			URL url = new URL(uri);
	        HttpURLConnection getConnection = (HttpURLConnection) url.openConnection();
	        getConnection.setDoInput(true);
	        getConnection.setRequestMethod("GET");
	        
//	        // Authorization header
//	        String authString = "user:password";
//	        authenticationToken = "basic " + Base64.encodeToString(authString.getBytes(), Base64.NO_WRAP);
//	        Log.i("authenticationToken",authenticationToken);
//	        getConnection.setRequestProperty("Authorization", authenticationToken);

	        // Starts the query
	        getConnection.connect();
	        
	        Log.i("GET request: ", uri);
	        
	        int responseCode = getConnection.getResponseCode();
	        response.setResponseCode(responseCode);
	        
	        InputStream inStream = new BufferedInputStream(getConnection.getInputStream());
	        String responseText = CommunicationUtils.readStream(inStream);
	        Log.i("getResquestAuthorizationBasic Response:",responseText);
	        Log.e("Content Type", getConnection.getContentType());
	        
	        String contentType = CommunicationUtils.getContentType(getConnection.getContentType());
	        if(contentType.equals("json")){
	        	try {
	        		response.setResponseResult(new JSONObject(responseText));
	        	} catch (JSONException e){
	        		e.printStackTrace();
	        	}
	        } else if(contentType.equals("text/html")){
	        	//TODO...
	        }
	       
	        // close getConnections
	        inStream.close();
	        getConnection.disconnect();
		} catch(MalformedURLException e) {
			e.printStackTrace();
		} catch(IOException e) {
			if (e.getMessage().contains("authentication challenge")) {
				//401: Unauthorized
				response.setResponseCode(HttpURLConnection.HTTP_UNAUTHORIZED);
			}
			e.printStackTrace();
		}
		return response;
	}
	
	/**
	 * HTTP POST request
	 * ******************
	 * 
	 * @param url
	 * @param body
	 * @return
	 */
	private ServerResponse postRequest(String uri, String body) {
		return this.postRequestAuthorizationBasic(uri, body, Model.getAuthenticationToken());
	}
	
	/**
	 * HTTP POST request (Authorization: Basic)
	 * ******************************************
	 * 
	 * @param url
	 * @param body
	 * @param authenticationToken
	 * @return
	 */
	private ServerResponse postRequestAuthorizationBasic(String uri, String body, String authenticationToken) {
		// the string to store the response text from the server
        ServerResponse response= new ServerResponse();
		try {
			URL url = new URL(uri);
	        HttpURLConnection postConnection = (HttpURLConnection) url.openConnection();
	        //set the output to true, indicating you are outputting(uploading) POST data
	        postConnection.setDoOutput(true);
	        //once we set the output to true, we don't really need to set the request method to post, but I'm doing it anyway
	        postConnection.setRequestMethod("POST");
	        //set the length of the data we are sending to the server
	        int contentLenght = body.getBytes().length;
	        postConnection.setFixedLengthStreamingMode(contentLenght);
	        
	        // Authorization header
	        postConnection.setRequestProperty("Authorization", authenticationToken);
	        
	        // Content-type header
	        postConnection.setRequestProperty("Content-Type", "application/json");
	        
	        // Content-Length header
	        postConnection.setRequestProperty("Content-Length", ""+contentLenght);
	        
	        //send the POST out
	        PrintWriter out = new PrintWriter(postConnection.getOutputStream());
	        out.print(body);
	        out.close();
	        
	        //start listening to the stream
	        int responseCode = postConnection.getResponseCode();
	        InputStream inStream = new BufferedInputStream(postConnection.getInputStream());
	        String json = CommunicationUtils.readStream(inStream);
	        response = new ServerResponse(responseCode, new JSONObject(json));
	        
	        // close connections
	        inStream.close();
	        postConnection.disconnect();
		}
		catch(MalformedURLException e) {
			e.printStackTrace();
		}
		catch(IOException e) {
			e.printStackTrace();
		} 
		catch (JSONException e) {
			e.printStackTrace();
		}
		return response;
	}
	

}
