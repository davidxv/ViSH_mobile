//
//  StartViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "StartViewController.h"


#import "FormViewController.h"
#import "MovieRecordViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>


@interface StartViewController ()
<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSURL * currentMovie;
}

@end

@implementation StartViewController


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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Form"]) {
        
        FormViewController * fvc = (FormViewController*) segue.destinationViewController;
        
        fvc.movie = currentMovie;
        
    } else if ([segue.identifier isEqualToString:@"Show Movie Record"]) {
        
       
    }

}

- (IBAction) pickVideo:(id)sender {
    
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    currentMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    
    NSLog(@"He seleccionado la pelicula: %@", currentMovie);
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    [self performSegueWithIdentifier:@"Show Form" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"He cancelado la seleccion de una pelicula");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



@end
