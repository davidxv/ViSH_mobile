/**
 * Manages every call to the ViSH API and its result.
 */
package dit.upm.es.ging.vishmobile.core;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.Log;


/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class CommunicationManager {
	
	//Constants
	private static final String lineEnd = "\r\n";
	private static final String twoHyphens = "--";
	private static final String boundary =  "----WebKitFormBoundaryo5L8LSN7JKaL1jud";
	
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
		
		if (authenticationToken == null) {
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
	 * @throws UnsupportedEncodingException 
	 */
	public static ServerResponse uploadDocument(Uri fileUri, String title, String description) {
		return uploadDocument();
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
	        getConnection.setRequestProperty("Authorization", authenticationToken);

	        // Starts the query
	        getConnection.connect();
	        
//	        Log.i("GET request: ", uri);
	        
	        int responseCode = getConnection.getResponseCode();
	        response.setResponseCode(responseCode);
	        
	        InputStream inStream;
	        if(CommunicationUtils.isErrorResponseCode(responseCode)){
	        	inStream = getConnection.getErrorStream();
	        } else {
	        	inStream = getConnection.getInputStream();
	        }
  
	        InputStream inBufStream = new BufferedInputStream(inStream);
	        String responseText = CommunicationUtils.readStream(inBufStream);
	        inStream.close();
	        
	        String contentType = CommunicationUtils.getContentType(getConnection.getContentType());
	        if(contentType.equals(Constants.FORMAT_JSON)){
	        	try {
	        		response.setResponseResult(new JSONObject(responseText));
	        	} catch (JSONException e){
	        		e.printStackTrace();
	        	}
	        } else if(contentType.equals(Constants.FORMAT_HTML)){
	        	//TODO...
	        }
	       
	        // Close getConnections
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
	private static ServerResponse postRequest(String uri, String body) {
		return postRequestAuthorizationBasic(uri, body, Model.getAuthenticationToken());
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
	private static ServerResponse postRequestAuthorizationBasic(String uri, String body, String authenticationToken) {
		// the string to store the response text from the server
        ServerResponse response= new ServerResponse();
		try {
			URL url = new URL(uri);
	        HttpURLConnection postConnection = (HttpURLConnection) url.openConnection();
	        //set the output to true, indicating you are outputting(uploading) POST data
	        postConnection.setDoOutput(true);
	        postConnection.setDoInput(true);
	    	postConnection.setUseCaches(false);
	        //once we set the output to true, we don't really need to set the request method to post, but I'm doing it anyway
	        postConnection.setRequestMethod("POST");
	        //set the length of the data we are sending to the server
	        int contentLenght = body.getBytes().length;
	        postConnection.setFixedLengthStreamingMode(contentLenght);
	        
	        // Authorization header
	        postConnection.setRequestProperty("Authorization", authenticationToken);
	        
	        postConnection.setRequestProperty("Connection", "Keep-Alive");
	        postConnection.setRequestProperty("Content-Type", "multipart/form-data;boundary="+boundary);
	        
	        // Content-Length header
	        postConnection.setRequestProperty("Content-Length", ""+contentLenght);
	        
	        //send the POST out
//	        OutputStreamWriter outWriter = new OutputStreamWriter(postConnection.getOutputStream(),"UTF8");
	        OutputStreamWriter outWriter = new OutputStreamWriter(postConnection.getOutputStream());
	        BufferedWriter out = new BufferedWriter(outWriter);
	        out.write(body);
	        out.flush();
	        out.close();
	        
	        //start listening to the stream
	        int responseCode = postConnection.getResponseCode();
	        response.setResponseCode(responseCode);
	        Log.i("responseCode",Integer.toString(responseCode));
	
	        
	        InputStream inStream;
	        if(CommunicationUtils.isErrorResponseCode(responseCode)){
	        	inStream = postConnection.getErrorStream();
	        } else {
	        	inStream = postConnection.getInputStream();
	        }
	        InputStream inBufStream = new BufferedInputStream(inStream);
	        String responseText = CommunicationUtils.readStream(inBufStream);
	        inStream.close();
	        
//	        Log.e("responseText",responseText);
	        
	        String contentType = CommunicationUtils.getContentType(postConnection.getContentType());
	        if(contentType.equals(Constants.FORMAT_JSON)){
	        	try {
	        		response.setResponseResult(new JSONObject(responseText));
	        	} catch (JSONException e){
	        		e.printStackTrace();
	        	}
	        } else if(contentType.equals(Constants.FORMAT_HTML)){
	        	//TODO...
	        }
	        
	        // close connections
	        postConnection.disconnect();
		}
		catch(MalformedURLException e) {
			e.printStackTrace();
		}
		catch(IOException e) {
			e.printStackTrace();
		}
		return response;
	}

	public static ServerResponse uploadDocument(){
		//Testing
		
		
		String pathToOurFile = "/mnt/sdcard/Pictures/VishPictures/test.jpg";
		String urlServer = Constants.SERVER_URI + Constants.DOCUMENTS_PATH;
		String body = "";
		
		try {
			File file = new File(pathToOurFile);
			FileInputStream fileInputStream;
			fileInputStream = new FileInputStream(file);
			String sfile = CommunicationUtils.readStream(fileInputStream);
			fileInputStream.close();
			
			body += twoHyphens + boundary + lineEnd;
			body += "Content-Disposition: form-data; name=\"document[file]\";filename=\"" + "test" +"\"" + lineEnd;
			body += "Content-Type: image/jpeg" + lineEnd;
			body += lineEnd;
			body += sfile;
			body += lineEnd;
			body += twoHyphens + boundary + lineEnd;
			body += "Content-Disposition: form-data; name=\"document[title]\";" + lineEnd;
			body += lineEnd;
			body += "Title";
			body += lineEnd;
			body += twoHyphens + boundary + lineEnd;
			body += "Content-Disposition: form-data; name=\"document[description]\";" + lineEnd;
			body += lineEnd;
			body += "Description";
			body += lineEnd;
			body += twoHyphens + boundary + lineEnd;
			body += "Content-Disposition: form-data; name=\"document[owner_id]\";" + lineEnd;
			body += lineEnd;
			body += "1";
			body += lineEnd;
			body += twoHyphens + boundary + twoHyphens + lineEnd;
		} catch (FileNotFoundException e){
			e.printStackTrace();
		} catch (UnsupportedEncodingException e){
			e.printStackTrace();
		} catch(IOException e){
			e.printStackTrace();
		}
		return postRequestAuthorizationBasic(urlServer, body, Model.getAuthenticationToken());
	}
	

	

}
