/**
 * Manages the user login process.
 */
package dit.upm.es.ging.vishmobile.activities;

import java.io.UnsupportedEncodingException;

import dit.upm.es.ging.vishmobile.R;
import dit.upm.es.ging.vishmobile.core.CommunicationManager;
import dit.upm.es.ging.vishmobile.core.CommunicationUtils;
import dit.upm.es.ging.vishmobile.core.Model;
import dit.upm.es.ging.vishmobile.core.ServerResponse;
import dit.upm.es.ging.vishmobile.utils.UIutils;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;


/**
 * @author Daniel Gallego Vico
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
        
        // Ok button
        Button okButton = (Button)findViewById(R.id.loginButton);
        okButton.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO validate username and password
				
				// generate authentication token
				String username = mUsernameText.getText().toString();
				String password = mPasswordText.getText().toString();
				String authToken = "";
				try {
					authToken = CommunicationUtils.generateAuthenticationTokenFromUserPassword(username, password);
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
				// execute the login process
				new LoginTask().execute(authToken);
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
    		this.progressDialog = ProgressDialog.show(LoginActivity.this, getString(R.string.loading), getString(R.string.loading));
    	}
    	
    	protected ServerResponse doInBackground(String... params) {
			authenticationToken = params[0];
			ServerResponse result = CommunicationManager.getInstance().checkAuthenticationTokenValidity(authenticationToken);
			
			return result;
		}
    	
    	protected void onPostExecute(ServerResponse response) {
    		// hide progress dialog
    		this.progressDialog.hide();

    		Log.i("ServerResponse with responseCode", Integer.toString(response.getResponseCode()));
    		
//    		// check result
    		if(response.getResponseCode() == 200) {
    			// save authorization token in the model
    			Model.setAuthenticationToken(authenticationToken);
    			// go to the main activity
    			Intent i = new Intent(LoginActivity.this, MainActivity.class);
    			startActivity(i);
    		} else {
    			// Inform the user about the problem
    			UIutils.showDialogToUser(LoginActivity.this, getString(R.string.login_error_title), getString(R.string.login_error_text));
    		}
    	}
    	
    }

}
