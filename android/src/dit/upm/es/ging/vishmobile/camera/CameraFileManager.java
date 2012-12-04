/**
 * Manages the files captured by the camera 
 */
package dit.upm.es.ging.vishmobile.camera;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import android.net.Uri;
import android.os.Environment;
import android.util.Log;

/**
 * @author Daniel Gallego Vico
 *
 */
public class CameraFileManager {
	
	// Codes for media types
	public static final int MEDIA_TYPE_IMAGE = 1;
	public static final int MEDIA_TYPE_VIDEO = 2;
	
	// Directory for storing files
	public static final String CAMERA_DIRECTORY = "Vish";
	
	/**
	  * Create a file Uri for saving an image or video
	  * 
	  * @param type
	  * @return
	  */
	 public static Uri getOutputMediaFileUri(int type) {
	       return Uri.fromFile(getOutputMediaFile(type));
	 }

	 
	 /**
	  * Create a File for saving an image or video
	  * 
	  * @param type
	  * @return
	  */
	 public static File getOutputMediaFile(int type) {
	     // To be safe, you should check that the SDCard is mounted
	     // using Environment.getExternalStorageState() before doing this.
		 
	     File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(
	               Environment.DIRECTORY_DCIM), CAMERA_DIRECTORY);
	     // This location works best if you want the created images to be shared
	     // between applications and persist after your app has been uninstalled.

	     // Create the storage directory if it does not exist
	     if (! mediaStorageDir.exists()){
	         if (! mediaStorageDir.mkdirs()){
	             Log.d("MyCameraApp", "failed to create directory");
	             return null;
	         }
	     }

	     // Create a media file name
	     String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.ENGLISH).format(new Date());
	     File mediaFile;
	     if (type == MEDIA_TYPE_IMAGE) {
	         mediaFile = new File(mediaStorageDir.getPath() + File.separator +
	         "IMG_"+ timeStamp + ".jpg");
	     } else if(type == MEDIA_TYPE_VIDEO) {
	         mediaFile = new File(mediaStorageDir.getPath() + File.separator +
	         "VID_"+ timeStamp + ".mp4");
	     } else {
	         return null;
	     }

	     return mediaFile;
	 }
}
