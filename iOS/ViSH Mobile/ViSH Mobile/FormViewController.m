//
//  FormViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "FormViewController.h"
#import "LoginViewController.h"
#import "NSData+Base64.h"

#import "Constants.h"



@interface FormViewController () <UIAlertViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *bodyField;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * actIndicator;



@end

@implementation FormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background1.png"]];
        imageView.contentMode = UIViewContentModeTop;
        [self.tableView setBackgroundView:imageView];
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background5.png"]];
        imageView.contentMode = UIViewContentModeTop;
        [self.tableView setBackgroundView:imageView];
    }
    
    self.bodyField.delegate = self;
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //-- Authenticate
    [self setWaitingConnectionState:YES];
    
    [LoginViewController authenticate:^(BOOL auth) {
        [self setWaitingConnectionState:NO];
        
        if (!auth) {
            [self performSegueWithIdentifier:@"Show Login" sender:self];
        }
    }];
    
    //--
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email = [def stringForKey:@"email"];
    self.emailLabel.text = email ? email: NSLocalizedString(@"No Logged",
                                                            @"No Logged");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.uploadButton.enabled = !waiting;
    self.logoutButton.enabled = !waiting;
}


-(IBAction)nextTextField:(id)sender {

    [self.bodyField becomeFirstResponder];
}

-(IBAction)editingTextField:(id)sender {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    
}

-(IBAction)endEditingTextField:(id)sender {
    return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

-(void) textViewDidBeginEditing:(UITextView *)textView  {
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction) hideKbd:(id)sender {
    
    [self.titleField resignFirstResponder];
    [self.bodyField resignFirstResponder];
    return;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}


- (IBAction)createPost:(id)sender
{
    [self createPostWithBody:self.fileData
                    filename:self.filename
                 contentType:self.contentType];
}

- (void) createPostWithBody:(NSData*)file
                   filename:(NSString*)filename
                contentType:(NSString*)contentType {
    
    //-- create request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:100];
    [request setHTTPMethod:@"POST"];
    
    //-- HTTP header: Basic authentication
    
    // Get authentication data from User Defaults:
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email = [def stringForKey:@"email"];
    NSString * password = [def stringForKey:@"password"];
    
    // set the HTTP header:
    NSString *user_password = [NSString stringWithFormat:@"%@:%@", email, password];
    NSData * user_password_data = [user_password dataUsingEncoding:NSUTF8StringEncoding];
    NSString * u_p_d_base64 = [user_password_data base64EncodedString];
    NSString *basic_auth_value = [NSString stringWithFormat:@"Basic %@", u_p_d_base64];
    [request setValue:basic_auth_value forHTTPHeaderField:@"Authorization"];
    
    //-- HTTP header: Content-Type is form multipart  
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *boundary = @"----------AQWSFH0g3hbqegZKa6zdzd";
    
    [request     setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
       forHTTPHeaderField: @"Content-Type"];
    
    //-- post body
    
    NSMutableData *body = [NSMutableData data];

    // Dictionary that holds post parameters.
    NSDictionary* _params = @{
    @"document[title]": self.titleField.text,
    @"document[description]": self.bodyField.text
    };
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    // name of the post parameter for the file to upload:
    NSString* fileParamName = @"document[file]";
    
    
    // add file data
    if (file != nil) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamName, filename]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",contentType]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:file];
        [body appendData:[[NSString stringWithFormat:@"\r\n"]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // The end of the multipart body
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    
    //-- HTTP header: Content-length
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //-- the URL

    NSURL* requestURL = [NSURL URLWithString:VISH_URL_DOCS];
    [request setURL:requestURL];
    
    [self setWaitingConnectionState:YES];
    
    [self hideKbd:self];
    
    dispatch_queue_t queue = dispatch_queue_create("upload queue", NULL);
    
    dispatch_async(queue, ^{
        // Realizar la petición
        NSHTTPURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&response
                                                          error:&error];
    
        NSInteger code = [response statusCode];
        NSString * locSC = [NSHTTPURLResponse localizedStringForStatusCode:code];
        NSLog(@"HTTP Response status code = %d (%@)", code, locSC);
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self setWaitingConnectionState:NO];
        });
        
        NSLog(@"%d", code);
        
        if (data != nil && code == 201) {
            NSLog(@"Exito");
            
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:NSLocalizedString(@"Alert Upload Success Title",@"Title")
                                       message:NSLocalizedString(@"Alert Upload Success Message",@"Message")
                                       delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Alert Upload Success Cancel",@"Cancel")
                                       otherButtonTitles:nil];
                [alert show];
            });
        } else {
            NSLog(@"Fallo");
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:NSLocalizedString(@"Alert Upload Error Title",@"Title")
                                       message:NSLocalizedString(@"Alert Upload Error Message",@"Message")
                                       delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"Alert Upload Error Cancel",@"Cancel")
                                       otherButtonTitles:NSLocalizedString(@"Alert Upload Error Retry",@"Retry"),nil];
                
                [alert show];
            });
        }
    });

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000 // Compiling for iOS < 6.0
    dispatch_release(queue);
#endif
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"Upload Done" sender:self];
    }
}

#pragma mark - Segues

- (IBAction) loggedIn:(UIStoryboardSegue*)segue
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email = [def stringForKey:@"email"];
    self.emailLabel.text = email ? email: NSLocalizedString(@"No Logged",
                                                            @"No Logged");
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
      if ([segue.identifier isEqualToString:@"Do Log Out"]) {
          
          [LoginViewController logout];
    
      } else if ([segue.identifier isEqualToString:@"Upload Done"]) {

      
      } else if ([segue.identifier isEqualToString:@"Show Login"]) {

      } else if ([segue.identifier isEqualToString:@"Show Login"]) {
          
      }

}

@end
