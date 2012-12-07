//
//  StartViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "StartViewController.h"
#import "FormViewController.h"
#import "WebSiteViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface StartViewController ()
<UINavigationControllerDelegate,UIImagePickerControllerDelegate,
UIPopoverControllerDelegate>

@property (nonatomic,strong) NSData*   selectedData;
@property (nonatomic,strong) NSString* selectedFilename;
@property (nonatomic,strong) NSString* selectedContentType;

@property (nonatomic, strong) UIImagePickerController* mediaPicker;

@property (nonatomic, strong) UIPopoverController* mediaPickerPopover;

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundView:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            [self showCameraPicker:cell];
            break;
        }

        case 1:
        {
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            [self showGalleryPicker:cell];
            break;
        }

        case 2:
        {
            [self goVishHome];
            break;
        }

        default:
            break;
    }
}



#pragma mark - Actions: Show Pickers, Show Web

- (IBAction) showCameraPicker:(UIView*)sender
{
    // Checking if source type is available:
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    
    self.mediaPicker = [[UIImagePickerController alloc] init];
    self.mediaPicker.delegate = self;
    self.mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.mediaPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.mediaPicker.allowsEditing = NO;
    self.mediaPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    
    [self presentViewController:self.mediaPicker
                       animated:YES
                     completion:nil];
    
}

- (IBAction) showGalleryPicker:(UIView*)sender
{
     // Checking if source type is available:
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    
    self.mediaPicker = [[UIImagePickerController alloc] init];
    self.mediaPicker.delegate = self;
    self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mediaPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    self.mediaPicker.allowsEditing = NO;
    self.mediaPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.mediaPickerPopover = [[UIPopoverController alloc]
                    initWithContentViewController:self.mediaPicker];
        
        self.mediaPickerPopover.delegate = self;
        
        [self.mediaPickerPopover presentPopoverFromRect:sender.frame
                                  inView:self.view
                permittedArrowDirections:UIPopoverArrowDirectionAny
                                animated:YES];
    } else {
        [self presentViewController:self.mediaPicker
                           animated:YES
                         completion:nil];
    }
}


- (IBAction) goVishHome
{
    UINavigationController *nc = [self.splitViewController.viewControllers lastObject];
    WebSiteViewController* wsvc = (id) nc.topViewController;
    [wsvc goHome];
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Selected media type = %@", [info objectForKey:UIImagePickerControllerMediaType]);
    
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSURL * url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSLog(@"Selected media URL = %@", url);
        
        self.selectedData = [NSData dataWithContentsOfURL: url];
        self.selectedFilename = @"movie.mov";
        self.selectedContentType = @"video/quicktime";
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UISaveVideoAtPathToSavedPhotosAlbum([url path], nil, nil, nil);
        }
        
    } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        
        NSLog(@"Selected media image.");
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        self.selectedData = UIImageJPEGRepresentation(image, 1);
        self.selectedFilename = @"image.jpg";
        self.selectedContentType = @"image/jpg";
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if ([info objectForKey:UIImagePickerControllerReferenceURL] == nil) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }
        
    } else {
        NSLog(@"Error in info data from UIImagePickerController");
        
        [self dismissViewControllerAnimated:NO completion:NULL];
        return;
    }
    
    self.mediaPicker = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (self.mediaPickerPopover) {
            [self.mediaPickerPopover dismissPopoverAnimated:YES];
            self.mediaPickerPopover = nil;
            
            [self performSegueWithIdentifier:@"Show Form" sender:self];
        } else {
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
            
            [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self performSegueWithIdentifier:@"Show Form" sender:self];
                                 }];
        }
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self performSegueWithIdentifier:@"Show Form" sender:self];
                                 }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Segues


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Form"]) {
        
        FormViewController * fvc = (FormViewController*) segue.destinationViewController;
        fvc.fileData = self.selectedData;
        fvc.contentType = self.selectedContentType;
        fvc.filename = self.selectedFilename;
    }
}

- (IBAction) unwindHome:(UIStoryboardSegue*)segue
{
    NSLog(@"START:Recibida solicitud de cancelacion: %@",segue.identifier);
}

@end
