/**
 * Main activity of Wishtagram
 */
package dit.upm.es.ging.vishmobile.activities;

import java.net.HttpURLConnection;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.camera.CameraFileManager;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.Model;
import dit.upm.es.ging.vishmobile.core.ServerResponse;
import dit.upm.es.ging.vishmobile.utils.UIutils;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class MainActivity extends Activity {
	
	// Codes for camera actions
	private final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 100;
	private final int CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE = 200;
	
	// Codes for gallery picking actions
	private final int PICK_IMAGE_CODE = 10;
	private final int PICK_VIDEO_CODE = 20;
	
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		 super.onCreate(savedInstanceState);
        
        setContentView(R.layout.activity_main);
        
        // Capture image button
        Button captureImage = (Button)findViewById(R.id.imageButton);
        captureImage.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// create Intent to take a picture and return control to the calling application
			    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);				   
			    // create a file to save the image and save it in the Model
			    Uri fileUri = CameraFileManager.getOutputMediaFileUri(CameraFileManager.MEDIA_TYPE_IMAGE);
			    Model.setFileUri(fileUri);
			    // set the image file name
			    intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri); 
			    // start the image capture Intent
			    startActivityForResult(intent, CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE);
			}
		});
        
        // Capture video button
        Button captureVideo = (Button)findViewById(R.id.videoButton);
        captureVideo.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				//create new Intent
			    Intent intent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
			    // create a file to save the video
			    Uri fileUri = CameraFileManager.getOutputMediaFileUri(CameraFileManager.MEDIA_TYPE_VIDEO);
			    Model.setFileUri(fileUri);
			    // set the image file name
			    intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);  
			    // set the video image quality to high
			    intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1); 
			    // start the Video Capture Intent
			    startActivityForResult(intent, CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE);
			}
		});
        
        // Use file from gallery
        Button fromGallery = (Button)findViewById(R.id.galleryButton);
        fromGallery.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO pick a image/video from the gallery
				Intent intent = new Intent();
				intent.setType("image/*");
				intent.setAction(Intent.ACTION_GET_CONTENT);
				startActivityForResult(Intent.createChooser(intent, "Select Picture"), PICK_IMAGE_CODE);
				// TODO: http://stackoverflow.com/questions/2507898/how-to-pick-an-image-from-gallery-sd-card-for-my-app-in-android
			}
		}); 
        
//	        Testing
//	        CommunicationManager.uploadTestDocument();
	 }

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
	    MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.activity_main, menu);
	    return true;
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
	    // Handle menu item selection
	    switch (item.getItemId()) {
	        case R.id.menu_logout:
	            // remove credentials and user information
	        	Model.logout(MainActivity.this);
	        	UIutils.showToast(getApplicationContext(), getString(R.string.msg_logout));
	            return true;
	        default:
	            return super.onOptionsItemSelected(item);
	    }
	}
	 
	 @Override
	 protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		 // response for images
	     if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE) {
	         if (resultCode == RESULT_OK) {
	        	 Uri fileUri = Model.getFileUri();
	             // Image captured and saved to fileUri specified in the Intent
	        	 // data.getData() is null, because the file path has been specified in the MediaStore.EXTRA_OUTPUT option.
	        	 if(fileUri != null){
	        		 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","Image captured and saved to " + fileUri.toString());
	        	 } else {
	        		 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","file URI is null");
	        	 }
	        	 // check credentials to do login if necessary 
	        	 new CheckCredentialsTask().execute();
	        	 
	         } else if (resultCode == RESULT_CANCELED) {
	             // User cancelled the image capture
	        	 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","User cancelled the image capture");
	         } else {
	             // Image capture failed, advise user
	        	 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","Image capture failed");
	         }
	     }
	     // response for videos
	     if (requestCode == CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE) {
	         if (resultCode == RESULT_OK) {
	        	 Uri fileUri = Model.getFileUri();
	             // Video captured and saved to fileUri specified in the Intent
	        	 if(fileUri != null){
	        		 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","Video captured and saved to " + fileUri.toString());
	        	 } else {
	        		 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","file URI is null");
	        	 }
	        	 // check credentials to do login if necessary 
	        	 new CheckCredentialsTask().execute();
	        	 
	         } else if (resultCode == RESULT_CANCELED) {
	             // User cancelled the video capture
	        	 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","User cancelled the video capture");
	         } else {
	             // Video capture failed, advise user
	        	 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","Video capture failed");
	         }
	     }
	 }
	 
	 
	 /**
     * Check if the user is logged in the system by
     * checking the credentials stored in the model.
     * 
     * If no credentials are stored, or they are invalid,
     * ask the user to do login.
     */
	 private class CheckCredentialsTask extends AsyncTask<String, Void, ServerResponse> {
    	
    	private ProgressDialog progressDialog;
    	private String authenticationToken;
    	
    	protected void onPreExecute() {
    		// show dialog information
    		this.progressDialog = ProgressDialog.show(MainActivity.this, getString(R.string.loading), getString(R.string.loading));
    	}
    	
    	protected ServerResponse doInBackground(String... params) {
			authenticationToken = Model.getAuthenticationToken();
			if(authenticationToken != null) {
				ServerResponse result = CommunicationManager.getInstance().checkAuthenticationTokenValidity(authenticationToken);
				return result;
			}
			else {
				return null;
			}
		}
    	
    	protected void onPostExecute(ServerResponse response) {
    		this.progressDialog.dismiss();
    		
    		if((response!=null)&&(response.getResponseCode() == HttpURLConnection.HTTP_OK)) {
    			// As the credentials are valid, go to Upload Document
    			Intent i = new Intent(MainActivity.this, UploadDocumentActivity.class);
    			startActivity(i);
    			MainActivity.this.finish();
    		} 
    		else {
    			// Go to Login
    			Intent i = new Intent(MainActivity.this, LoginActivity.class);
    			startActivity(i);
    		}
    	}
    	
    }
	 
}
