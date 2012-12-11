//
//  WebSiteViewController.m
//  ViSH Mobile
//
//  Created by Santiago Pavón on 08/12/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import "WebSiteViewController.h"

#import "Constants.h"

@interface WebSiteViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation WebSiteViewController

- (void) awakeFromNib {
    
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.navigationItem.hidesBackButton = NO;
    
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithTitle:@"<<"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self.webView
                                                            action:@selector(goBack)];
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self.webView
                                                                             action:@selector(reload)];
    UIBarButtonItem* forward = [[UIBarButtonItem alloc] initWithTitle:@">>"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self.webView
                                                               action:@selector(goForward)];
    UIBarButtonItem* home = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home Button Title",@"Home")
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(goHome)];
    
    [self.navigationItem setRightBarButtonItems:@[home,forward,refresh,back]];
    
    self.title = @"ViSH";
 
    [self goHome];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) goHome
{
    NSURL *url = [NSURL URLWithString:VISH_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}


#pragma mark - Split view

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Upload Button Title",@"Upload");
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
