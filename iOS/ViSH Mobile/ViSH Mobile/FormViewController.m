//
//  FormViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "FormViewController.h"

#import "NSData+Base64.h"

@interface FormViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *bodyField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * actIndicator;

@end

@implementation FormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) hideKbd:(id)sender {
    
    [self.titleField resignFirstResponder];
    [self.bodyField resignFirstResponder];
}


// #define CORE_URL @"http://alipori2.dit.upm.es:3000/vish"
// #define CORE_URL @"http://localhost:3000/vish"
#define CORE_URL @"http://192.168.0.100:3000/vish"

#define VISH_URL @"http://vishub-test.global.dit.upm.es/documents.json"

- (IBAction)createPost
{
//    [self createPost_CORE];
    [self createPost_VISH];
}

- (void) createPost_VISH {
    
    //-- create request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
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
    
    
    // add movie data
    NSData *movieData = [NSData dataWithContentsOfURL:self.movie];
    if (movieData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"movie.mov\"\r\n", fileParamName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: video/quicktime\r\n\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:movieData];
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
        
        if (data != nil && code == 200) {
            NSLog(@"Exito");
            
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Subida terminada"
                                       message:@"El fichero se ha subido con exito."
                                       delegate:self
                                       cancelButtonTitle:@"ok"
                                       otherButtonTitles:nil];
                [alert show];
            });
        } else {
            NSLog(@"Fallo");
            dispatch_async( dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc]
                                       initWithTitle:@"Subida fallida"
                                       message:[NSString stringWithFormat:@"Error: %@", locSC]
                                       delegate:self
                                       cancelButtonTitle:@"ok"
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
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) createPost_CORE {
    
    // Dictionary that holds post parameters.
    // You can set your post parameters that your server accepts or programmed to accept.
    NSDictionary* _params = @{
    @"login": @"spg",
    @"password": @"1234",
    @"title": self.titleField.text,
    @"body": self.bodyField.text
    };
    
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"adjunto";
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString * boundary = BoundaryConstant;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add movie data
    NSData *movieData = [NSData dataWithContentsOfURL:self.movie];
    if (movieData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"movie.mov\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: video/quicktime\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:movieData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    // the server url to which the image (or the media) is uploaded.
    // Use your server url here
    NSURL* requestURL = [NSURL URLWithString:CORE_URL];
    [request setURL:requestURL];
    
    //  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // dispatch_queue_t queue = dispatch_queue_create("upload queue", NULL);
    
    // dispatch_async(queue, ^{
    // Realizar la petición
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    NSInteger code = [response statusCode];
    NSString * locSC = [NSHTTPURLResponse localizedStringForStatusCode:code];
    NSLog(@"HTTP Response status code = %d (%@)", code, locSC);
    
    //      dispatch_async( dispatch_get_main_queue(), ^{
    //         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //     });
    
    if (data != nil) {
        NSLog(@"Exito");
    } else {
        NSLog(@"Fallo");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    // });
    
}



@end
