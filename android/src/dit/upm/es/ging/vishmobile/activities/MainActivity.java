/**
 * Main activity of the application
 */
package dit.upm.es.ging.vishmobile.activities;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.camera.CameraFileManager;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

/**
 * @author Daniel Gallego Vico
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
	        
	 }
	 
	 @Override
	 protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		 // response for images
	     if (requestCode == CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE) {
	         if (resultCode == RESULT_OK) {
	             // Image captured and saved to fileUri specified in the Intent
	             Toast.makeText(this, "Image saved to:\n" + data.getData(), Toast.LENGTH_LONG).show();
	         } else if (resultCode == RESULT_CANCELED) {
	             // User cancelled the image capture
	         } else {
	             // Image capture failed, advise user
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
	 
}
