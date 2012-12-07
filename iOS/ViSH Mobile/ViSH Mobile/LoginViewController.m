//
//  LoginViewController.m
//  ViSH Mobile
//
//  Created by Álvaro Alonso on 11/28/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "LoginViewController.h"
#import "StartViewController.h"
#import "FormViewController.h"

#import "NSData+Base64.h"

#import "Constants.h"

static BOOL authenticated = NO;

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField* emailField;
@property (weak, nonatomic) IBOutlet UITextField* passwordField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* actIndicator;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signinButton;

@end


@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:imageView];
    
    // Fill in the email text field.
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email    = [def stringForKey:@"email"];
    NSString * password = [def stringForKey:@"password"];
    if (email) {
        self.emailField.text = email;
    }
    if (password) {
        self.passwordField.text = password;
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void) logout {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:nil forKey:@"password"];

    authenticated = NO;
}


- (void) setWaitingConnectionState:(BOOL)waiting
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:waiting];

    if (waiting) {
        [self.actIndicator startAnimating];
    } else {
        [self.actIndicator stopAnimating];
    }
    
    self.cancelButton.enabled = !waiting;
    self.signinButton.enabled = !waiting;
}

- (IBAction) editingTextField:(id)sender {

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];

}

- (IBAction) endEditingTextField:(id)sender {

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
}



- (IBAction) nextTextField:(id)sender {
    [self.passwordField becomeFirstResponder];
}

- (IBAction) hideKbd:(id)sender {
    
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (IBAction) signIn: (id)sender {
    
    [self hideKbd:self];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.emailField.text forKey:@"email"];
    [def setObject:self.passwordField.text forKey:@"password"];
    
    [self setWaitingConnectionState:YES];
 
    authenticated = NO;
    
    [LoginViewController authenticate:^(BOOL auth) {
        
        [self setWaitingConnectionState:NO];
        
        if (auth) {
            [self performSegueWithIdentifier:@"Logged In" sender:sender];
        }
    }];
}


+ (void) authenticate:(void(^)(BOOL ok))completion
{
    if (authenticated) {
        completion(YES);
        return;
    }
    
    //-- User Defaults:
    
    // Get authentication data from User Defaults:
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email = [def stringForKey:@"email"];
    NSString * password = [def stringForKey:@"password"];
    
    NSLog(@"Saved email = \"%@\"",email);
    NSLog(@"Saved password = \"%@\"",password);
    
    if ( !email || !password || [email isEqualToString:@""] || [password isEqualToString:@""]) {
        NSLog(@"Auth fail: there is no email or password.");
        
        UIAlertView * alert = [[UIAlertView alloc]
                               initWithTitle:@"Sign In incomplete"
                               message:@"Please, fill in email and password fields."
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [alert show];
        authenticated = NO;
        completion(NO);
        return;
    }
    
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Loging In"
                           message:@"Please wait..."
                           delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:nil];
    [alert show];
    
    //-- create request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:100];
    [request setHTTPMethod:@"POST"];
    
    //-- HTTP header: Basic authentication
    
    // set the HTTP header:
    NSString *user_password = [NSString stringWithFormat:@"%@:%@", email, password];
    NSData * user_password_data = [user_password dataUsingEncoding:NSUTF8StringEncoding];
    NSString * u_p_d_base64 = [user_password_data base64EncodedString];
    NSString *basic_auth_value = [NSString stringWithFormat:@"Basic %@", u_p_d_base64];
    [request setValue:basic_auth_value forHTTPHeaderField:@"Authorization"];
    
    //-- the URL
    
    NSURL* requestURL = [NSURL URLWithString:VISH_URL_AUTH];
    [request setURL:requestURL];
    
    dispatch_queue_t queue = dispatch_queue_create("auth queue", NULL);
    dispatch_async(queue, ^{

        // Realizar la petición
        NSHTTPURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
        NSInteger code = [response statusCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:-1 animated:YES];
        
            if (data != nil && code == 200) {
                NSLog(@"Auth success");
                authenticated = YES;
                completion(YES);
                
            } else if (data == nil) {
                
                NSLog(@"Connection fail. Error = %@",[error localizedDescription]);
                
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Connection Fail"
                                       message:@"I can not connect with the server."
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                [alert show];
                authenticated = NO;
                completion(NO);
                
            } else {
                
                NSLog(@"Auth fail. Code = %d. Error = %@",code,[error localizedDescription]);
                
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Bad credentials"
                                       message:@"Your email or password are incorrect. Please, try again."
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                [alert show];
                authenticated = NO;
                completion(NO);
            }
        });
    });
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000 // Compiling for iOS < 6.0
    dispatch_release(queue);
#endif
}


#pragma mark - Segues


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Logged In"]) {
        
        // Nothing to do.
        
    } else if ([segue.identifier isEqualToString:@"Login Cancelled"]) {

        NSLog(@"Cancelling login");
        
        // Nothing to do.

    }
    
}



@end
