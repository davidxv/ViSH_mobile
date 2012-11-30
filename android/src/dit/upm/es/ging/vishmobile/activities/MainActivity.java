package dit.upm.es.ging.vishmobile.activities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
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
import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.camera.CameraFileManager;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.Model;
import dit.upm.es.ging.vishmobile.core.ServerResponse;
import dit.upm.es.ging.vishmobile.utils.UIutils;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Mendez
 *
 */
public class MainActivity extends Activity {
	
	// Codes for camera actions
	private final int CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE = 100;
	private final int CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE = 200;
	
	// Codes for gallery picking actions
	private final int PICK_DOCUMENT_FROM_GALLERY_REQUEST_CODE = 300;
	
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		 super.onCreate(savedInstanceState);
        
        setContentView(R.layout.activity_main);
        
        Model.init(this);
        
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
			    
			    // Brokes in Gingerbread!!!
//			    intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);  

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
				// pick a image/video from the gallery
				Intent intent = new Intent();
				intent.setType("image/* video/*");
				// ACTION_PICK for using only the native gallery or ACTION_GET_CONTENT for every media app
				intent.setAction(Intent.ACTION_GET_CONTENT);
				startActivityForResult(Intent.createChooser(intent,getString(R.string.msg_select)), PICK_DOCUMENT_FROM_GALLERY_REQUEST_CODE);
			}
		});
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
		switch (requestCode) {
			// response for images
			case CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE:
				if (resultCode == RESULT_OK) {
		             // Image captured and saved to fileUri specified in the Intent
		        	 // data.getData() is null, because the file path has been specified in the MediaStore.EXTRA_OUTPUT option.
					 Uri fileUri = Model.getFileUri();
					 
		        	//Save filepath and check if login is required
		        	 Model.setFilePath(fileUri.getPath()); 
		        	 new CheckCredentialsTask().execute();
		         } else if (resultCode == RESULT_CANCELED) {
		             // User cancelled the image capture
		        	 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","User cancelled the image capture");
		         } else {
		             // Image capture failed, advise user
		        	 Log.d("CAPTURE_IMAGE_ACTIVITY_REQUEST_CODE","Image capture failed");
		         }
				break;
			// response for videos
			case CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE:
				if (resultCode == RESULT_OK) {
				    String videoPath = getRealPathFromVideoURI(data.getData());
				    //Save filepath and check if login is required
		            Model.setFilePath(videoPath);
		            new CheckCredentialsTask().execute();
		         } else if (resultCode == RESULT_CANCELED) {
		             // User cancelled the video capture
		        	 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","User cancelled the video capture");
		         } else {
		             // Video capture failed, advise user
		        	 Log.d("CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE","Video capture failed");
		         }
				break;
			// response for picking document from gallery
			case PICK_DOCUMENT_FROM_GALLERY_REQUEST_CODE:
				if(resultCode == RESULT_OK){
		            Uri selectedDocument = data.getData();
		            String[] filePathColumn = {MediaStore.Images.Media.DATA};
		            Cursor cursor = getContentResolver().query(selectedDocument, filePathColumn, null, null, null);
		            cursor.moveToFirst();
		            int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
		            String filePath = cursor.getString(columnIndex);
		            cursor.close();

		            //Save filepath and check if login is required
		            Model.setFilePath(filePath);
		        	new CheckCredentialsTask().execute();
		        } else if (resultCode == RESULT_CANCELED) {
		             // User cancelled the picking action
		        	 Log.d("PICK_DOCUMENT_FROM_GALLERY_REQUEST_CODE", "User cancelled the picking action");
		         } else {
		             // Picking action failed, advise user
		        	 Log.d("PICK_DOCUMENT_FROM_GALLERY_REQUEST_CODE", "Pick action failed");
		         }
				break;
			default:
				break;
		}
	 }
	 
	/*
	 * Get the real path of a video URI returned by the capture media intent.
	 */
	private String getRealPathFromVideoURI(Uri uri) {
        String[] proj = { MediaStore.Video.Media.DATA };
        Cursor cursor = managedQuery(uri, proj, null, null, null);

//      For API > 10
//      CursorLoader loader = new CursorLoader(mContext, uri, proj, null, null, null);
//	    Cursor cursor = loader.loadInBackground();
        
        int column_index = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA);
        cursor.moveToFirst();
        return cursor.getString(column_index);
    }
	
	/*
	 * Save the video returned by a videoIntent to a specific filePath
	 * Currently not used
	 */
	private void saveVideoToFile(Intent videoIntent,String filePath){
		   FileInputStream fis = null;
		   FileOutputStream fos = null;
		   File mCurrentVideoFile = null;
		   try {
				mCurrentVideoFile = new File(filePath);
				AssetFileDescriptor videoAsset = getContentResolver().openAssetFileDescriptor(videoIntent.getData(), "r");
				fis = videoAsset.createInputStream(); 
				fos = new FileOutputStream(mCurrentVideoFile);
				byte[] buffer = new byte[1024];
				int length;
				while ((length = fis.read(buffer)) > 0) {
				      fos.write(buffer, 0, length);
				 }  
				fis.close();
				fos.close();
		   } catch (IOException e) {
			   	e.printStackTrace();
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
    	
    	protected void onPreExecute() {
    		// show dialog information
    		this.progressDialog = ProgressDialog.show(MainActivity.this, getString(R.string.uploading), getString(R.string.uploading));
    	}
    	
    	protected ServerResponse doInBackground(String... params) {
			String authenticationToken = Model.getAuthenticationToken();
			ServerResponse result = null;
			if(authenticationToken != null) {
				result = CommunicationManager.getInstance().checkAuthenticationTokenValidity(authenticationToken);
			}
			return result;
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
