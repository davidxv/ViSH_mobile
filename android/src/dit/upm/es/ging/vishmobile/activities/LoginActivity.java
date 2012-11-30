/**
 * Manages the user login process.
 */
package dit.upm.es.ging.vishmobile.activities;

import java.net.HttpURLConnection;

import org.json.JSONException;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.CommunicationUtils;
import dit.upm.es.ging.vishmobile.core.Model;
import dit.upm.es.ging.vishmobile.core.ServerResponse;
import dit.upm.es.ging.vishmobile.utils.UIutils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;


/**
 * @author Daniel Gallego Vico
 * @author Aldo Gordillo Mendez
 *
 */
public class LoginActivity extends Activity {
	
	// UI elements
	private EditText mUsernameText;
	private EditText mPasswordText;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        
        // Login
        mUsernameText = (EditText)findViewById(R.id.username);
        
        // Password
        mPasswordText = (EditText)findViewById(R.id.password);
        
        // Cancel button
        Button cancelButton = (Button)findViewById(R.id.loginCancel);
        cancelButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent i = new Intent(LoginActivity.this, MainActivity.class);
				startActivity(i);
				LoginActivity.this.finish();
			}
		});
        
        // Ok button
        Button okButton = (Button)findViewById(R.id.loginButton);
        okButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// Generate authentication token
				String username = mUsernameText.getText().toString();
				String password = mPasswordText.getText().toString();
				String authToken = "";
				authToken = CommunicationUtils.generateAuthenticationTokenFromUserPassword(username, password);
				// execute the login process
				new LoginTask().execute(authToken);
			}
		});
        
        // Sign up
        TextView signUp = (TextView)findViewById(R.id.signUp);
        signUp.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// launch the ViSH web page in the browser
				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://vishub-test.global.dit.upm.es/users/sign_up"));
				startActivity(browserIntent);
			}
		});
    }
    
    
    /**
     * Manage the login process in order to check 
     * the validity of the credentials given
     */
    private class LoginTask extends AsyncTask<String, Void, ServerResponse> {
    	
    	private ProgressDialog progressDialog;
    	private String authenticationToken;
    	
    	protected void onPreExecute() {
    		// show dialog information
    		this.progressDialog = ProgressDialog.show(LoginActivity.this, getString(R.string.uploading), getString(R.string.uploading));
    	}
    	
    	protected ServerResponse doInBackground(String... params) {
			authenticationToken = params[0];
			ServerResponse result = CommunicationManager.getInstance().checkAuthenticationTokenValidity(authenticationToken);
			return result;
		}
    	
    	protected void onPostExecute(ServerResponse response) {
    		this.progressDialog.dismiss();
    		
    		if((response!=null)&&(response.getResponseCode() == HttpURLConnection.HTTP_OK)) {
    			// Save authorization token in the model
    			Model.setAuthenticationToken(LoginActivity.this,authenticationToken);
    			try {
    				Model.setUserName(LoginActivity.this, response.getResponseResult().get("name").toString());
    			} catch (JSONException e){
    				e.printStackTrace();
    			}
    			
    			// Go to the Upload Document activity
    			Intent intent = new Intent(LoginActivity.this, UploadDocumentActivity.class);
    			startActivity(intent);
    			LoginActivity.this.finish();
    		} else {
    			// Inform the user about the problem
    			UIutils.showDialog(LoginActivity.this, getString(R.string.login_error_title), getString(R.string.login_error_text));
    		}
    	}
    	
    }
}
