/**
 * 
 */
package dit.upm.es.ging.vishmobile.activities;

import java.net.HttpURLConnection;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.Model;
import dit.upm.es.ging.vishmobile.core.ServerResponse;
import dit.upm.es.ging.vishmobile.utils.UIutils;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Méndez
 *
 */
public class UploadDocumentActivity extends Activity {
	
	// UI elements
	private EditText mTitle;
	private EditText mDescription;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_upload_document);
		
		// Title
		mTitle = (EditText)findViewById(R.id.documentTitle);
		
		// Description
		mDescription = (EditText)findViewById(R.id.documentDescription);
		
		// Cancel button
        Button cancelButton = (Button)findViewById(R.id.uploadDocumentCancelButton);
        cancelButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent i = new Intent(UploadDocumentActivity.this, MainActivity.class);
				startActivity(i);
				UploadDocumentActivity.this.finish();
			}
		});
		
		// Ok button
        Button okButton = (Button)findViewById(R.id.uploadDocumentOkButton);
        okButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// Retrieve documents details
				String title = mTitle.getText().toString();
				String description = mDescription.getText().toString();
				// execute the upload task
				new UploadDocumentTask().execute(title, description);
			}
		});
	}
	
	
	/**
     * Task to upload the document selected/created to ViSH
     * 
     */
	 private class UploadDocumentTask extends AsyncTask<String, Void, ServerResponse> {
    	
    	private ProgressDialog progressDialog;
    	
    	protected void onPreExecute() {
    		// show dialog information
    		this.progressDialog = ProgressDialog.show(UploadDocumentActivity.this, getString(R.string.loading), getString(R.string.loading));
    	}
    	
    	protected ServerResponse doInBackground(String... params) {
			ServerResponse result = CommunicationManager.uploadDocument(Model.getFileUri().getPath(), params[0], params[1]);
			return result;
		}
    	
    	protected void onPostExecute(ServerResponse response) {
    		this.progressDialog.dismiss();
    		
    		if((response!=null)&&(response.getResponseCode() == HttpURLConnection.HTTP_OK)) {
    			// the document has been successfully uploaded
    			Intent i = new Intent(UploadDocumentActivity.this, MainActivity.class);
    			startActivity(i);
    			UploadDocumentActivity.this.finish();
    			UIutils.showToast(UploadDocumentActivity.this, getString(R.string.msg_upload_successful));
    		} 
    		else {
    			// the upload has failed
    			UIutils.showToast(UploadDocumentActivity.this, getString(R.string.msg_upload_fail));
    		}
    	}
    	
    }

}
