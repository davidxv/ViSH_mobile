/**
 * Main activity of the application
 */
package dit.upm.es.ging.vishmobile.activities;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.camera.CameraFileManager;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.Model;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
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
	
	// File management 
	private Uri fileUri;

	 @Override
	    public void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        
	        //Get data (authtoken, username, ...) stored in preferences
	        Model.init(this);
	        
	        if(Model.getAuthenticationToken()==null){
	        	//Go to login activity
	        	Intent i = new Intent(MainActivity.this, LoginActivity.class);
    			startActivity(i);
    			this.finish();
	        } else {
	        	//Stored credentials
    			Log.i("AuthToken",Model.getAuthenticationToken());
    			Log.i("Username",Model.getUserName());
	        }
	        
	        setContentView(R.layout.activity_main);
	        
	        // Capture image button
	        Button captureImage = (Button)findViewById(R.id.imageButton);
	        captureImage.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					// create Intent to take a picture and return control to the calling application
				    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);				   
				    // create a file to save the image
				    fileUri = CameraFileManager.getOutputMediaFileUri(CameraFileManager.MEDIA_TYPE_IMAGE);
				    Log.i("fileUri",fileUri.toString());
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
				    fileUri = CameraFileManager.getOutputMediaFileUri(CameraFileManager.MEDIA_TYPE_VIDEO);
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
				}
			}); 
	        
	        CommunicationManager.uploadDocument();
	 }
	 
	 @Override
	 protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		 // response for images
	     if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE) {
	         if (resultCode == RESULT_OK) {
	             // Image captured and saved to fileUri specified in the Intent
	        	 // data.getData() is null, because the file path has been specified in the MediaStore.EXTRA_OUTPUT option.
	        	 if(fileUri!=null){
	        		 Log.i("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","Image captured and saved to " + fileUri.toString());
	        	 } else {
	        		 Log.i("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","file URI is null");
	        	 }
	        	
	        	 showConfirmationDialog();
	         } else if (resultCode == RESULT_CANCELED) {
	             // User cancelled the image capture
	        	 Log.i("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","User cancelled the image capture");
	         } else {
	             // Image capture failed, advise user
	        	 Log.i("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","Image capture failed");
	         }
	     }
	     // response for videos
	     if (requestCode == CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE) {
	         if (resultCode == RESULT_OK) {
	             // Video captured and saved to fileUri specified in the Intent
	             Toast.makeText(this, "Video saved to:\n" + data.getData(), Toast.LENGTH_LONG).show();
	         } else if (resultCode == RESULT_CANCELED) {
	             // User cancelled the video capture
	         } else {
	             // Video capture failed, advise user
	         }
	     }
	 }
	 
	 private void showConfirmationDialog(){
		 AlertDialog.Builder builder = new AlertDialog.Builder(this);

		 builder.setTitle("Upload to ViSH");
		 builder.setMessage("Do you want confirm this action?");

		 builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {
		     public void onClick(DialogInterface dialog, int which) {
		         // Do do my action here
		    	 if(fileUri!=null){
		    		 CommunicationManager.uploadDocument(fileUri,"Title","Description");
		    	 } else {
		    		 Log.e("Error","fileURI IS NULL");
		    	 }
		         dialog.dismiss();
		     }
		 });

		 builder.setNegativeButton("NO", new DialogInterface.OnClickListener() {  
		     public void onClick(DialogInterface dialog, int which) {
		         dialog.dismiss();
		     }
		 });

		 AlertDialog alert = builder.create();
		 alert.show();
	 }
	 
}
