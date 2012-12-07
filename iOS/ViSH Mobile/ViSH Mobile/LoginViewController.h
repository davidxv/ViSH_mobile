//
//  LoginViewController.h
//  ViSH Mobile
//
//  Created by Álvaro Alonso on 11/28/12.
//  Copyright (c) 2012 UPM. All rights reserved.
//

@interface LoginViewController : UITableViewController

@property (nonatomic, strong) NSData * fileData;

+ (void) authenticate:(void(^)(BOOL ok))completion;

+ (void) logout;

@end
