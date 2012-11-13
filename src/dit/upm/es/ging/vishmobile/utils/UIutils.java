/**
 * User Interface utilities
 */
package dit.upm.es.ging.vishmobile.utils;

import dit.upm.es.ging.vishmobile.R;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;

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
    public static void showDialogToUser(Context context, String title, String message) {
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
}
