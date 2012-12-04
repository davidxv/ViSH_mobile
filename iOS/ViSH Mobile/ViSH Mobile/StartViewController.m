//
//  StartViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "StartViewController.h"

#import "FormViewController.h"
#import "LoginViewController.h"
#import "NSData+Base64.h"


@interface StartViewController ()
<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSData * currentFile;
}

@end

@implementation StartViewController

#define AUTH_URL @"http://vishub-test.global.dit.upm.es/home.json"

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:imageView];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Form"]) {
      
        FormViewController * fvc = (FormViewController*) segue.destinationViewController;
        fvc.src = self;
        fvc.fileData = currentFile;
        
    } else if ([segue.identifier isEqualToString:@"Show Login"]) {
        
        LoginViewController * lvc = (LoginViewController*) segue.destinationViewController;
        lvc.src = self;
        lvc.fileData = currentFile;
    }
}

-(IBAction)goCamera:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
    
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
    
}

-(IBAction)goGallery:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

+ (BOOL) authenticate {
    
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

    //-- the URL
    
    NSURL* requestURL = [NSURL URLWithString:AUTH_URL];
    [request setURL:requestURL];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    // Realizar la petición
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];

    NSInteger code = [response statusCode];
        
    if (data != nil && code == 200) {
        NSLog(@"Auth success");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return YES;
    } else {
        NSLog(@"Auth fail");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return NO;
    }

}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Loging In"
                           message:@"Please wait..."
                           delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:nil];
    [alert show];

    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL * url = [info objectForKey:UIImagePickerControllerMediaURL];
        currentFile = [NSData dataWithContentsOfURL: url];
        UISaveVideoAtPathToSavedPhotosAlbum([url path], nil, nil, nil);
        NSLog(@"Selected media type Video %@", url);
    } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        currentFile = UIImageJPEGRepresentation(image, 1);
        if ([info objectForKey:UIImagePickerControllerReferenceURL] == nil) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        NSLog(@"Selected media type Image %@", image);
    } else {
        NSLog(@"Error in info data from UIImagePickerController");
    }
    
    BOOL auth = [StartViewController authenticate];
    
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    if (!auth) {
        [self performSegueWithIdentifier:@"Show Login" sender:self];
    } else {
        [self performSegueWithIdentifier:@"Show Form" sender:self];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
