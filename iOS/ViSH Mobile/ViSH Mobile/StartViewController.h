//
//  StartViewController.h
//  ViSH Mobile
//
//  Created by Santiago Pavón on 19/11/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UITableViewController

-(IBAction)goCamera:(id)sender;

-(IBAction)goGallery:(id)sender;

+(BOOL)authenticate;

@end
