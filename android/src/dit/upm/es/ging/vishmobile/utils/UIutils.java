/**
 * User Interface utilities
 */
package dit.upm.es.ging.vishmobile.utils;

import dit.upm.es.ging.vishmobile.R;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

/**
 * @author Daniel Gallego Vico
 *
 */
public class UIutils {

	/**
     * Show an alert dialog to the user with the title and message provided.
     *
     * @param context
     * @param title
     * @param message
     */
    public static void showDialog(Context context, String title, String message) {
    	AlertDialog.Builder builder = new AlertDialog.Builder(context);
    	builder.setMessage(message)
    			.setTitle(title)
    			.setCancelable(false)
    			.setNeutralButton(context.getString(R.string.button_ok), new DialogInterface.OnClickListener() {
    	           public void onClick(DialogInterface dialog, int id) {
    	                dialog.cancel();
    	           }
    	       });
    	AlertDialog alert = builder.create();
    	alert.show();
    }
    
    /**
     * Show a toast message to the user with the text provided.
     * 
     * @param context
     * @param msg
     */
    public static void showToast(Context context, String text) {
    	int duration = Toast.LENGTH_SHORT;
    	Toast toast = Toast.makeText(context, text, duration);
    	toast.show();
    }
}
