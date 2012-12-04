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
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:imageView];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

-(IBAction)editingTextField:(id)sender {

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

}

-(IBAction)endEditingTextField:(id)sender {

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
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
                               initWithTitle:@"Bad credentials"
                               message:@"Your username or password are incorrect. Please, try again."
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
