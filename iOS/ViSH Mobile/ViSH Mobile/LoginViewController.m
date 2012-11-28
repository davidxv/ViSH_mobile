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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;

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
        fvc.src = self.src;
        fvc.fileData = self.fileData;
        
    }
}

-(IBAction)nextTextField:(id)sender {
    [self.password becomeFirstResponder];
}

- (IBAction) hideKbd:(id)sender {
    
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (IBAction)signIn: (id)sender {
    
    [self hideKbd:self];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.username.text forKey:@"email"];
    [def setObject:self.password.text forKey:@"password"];
    
    if ([StartViewController authenticate]) {
         [self performSegueWithIdentifier:@"Show Form" sender:self];
    } else {
        UIAlertView * alert = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Wrong credentials"
                               delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [alert show];
    }
    
    
}

- (IBAction)cancel: (id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}


@end
