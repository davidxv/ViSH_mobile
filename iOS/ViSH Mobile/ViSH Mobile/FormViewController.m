//
//  FormViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "FormViewController.h"

#import "NSData+Base64.h"

@interface FormViewController () <UIAlertViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *bodyField;
@property (weak, nonatomic) IBOutlet UILabel *userField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * actIndicator;

@end

@implementation FormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
	
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:imageView];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString * email = [def stringForKey:@"email"];
    self.userField.text = [NSString stringWithFormat:@"User: %@", email];
    
    self.bodyField.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel: (id)sender {
    
    [self.navigationController popToViewController: self.src animated:YES];
    
}

- (IBAction)logOut: (id)sender {
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:nil forKey:@"email"];
    [def setObject:nil forKey:@"password"];
    
    [self.navigationController popToViewController: self.src animated:YES];
    
}

-(IBAction)nextTextField:(id)sender {
    [self.bodyField becomeFirstResponder];
}

-(IBAction)editingTextField:(id)sender {
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}

-(IBAction)endEditingTextField:(id)sender {
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) textViewDidBeginEditing:(UITextView *)textView  {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
}

#define VISH_URL @"http://vishub-test.global.dit.upm.es/documents.json"

- (IBAction)createPost:(id)sender
{
    [self createPostWithBody:self.fileData];
}

- (void) createPostWithBody: (NSData*) file {
    
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
    NSString *boundary = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
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
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"movie.mov\"\r\n", fileParamName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: video/quicktime\r\n\r\n"
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

    NSURL* requestURL = [NSURL URLWithString:VISH_URL];
    [request setURL:requestURL];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.actIndicator startAnimating];
    
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
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.actIndicator stopAnimating];
        });
        
        NSLog(@"%d", code);
        
        if (data != nil && code == 201) {
            NSLog(@"Exito");
            
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Success"
                                       message:@"The document has been successfully uploaded."
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                [alert show];
            });
        } else {
            NSLog(@"Fallo");
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Error"
                                       message:@"The upload has failed! Please try again."
                                       delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                
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
     [self.navigationController popToViewController: self.src animated:YES];
}

@end
