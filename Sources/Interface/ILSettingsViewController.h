//
//  ILSettingsViewController.h
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 Bastian Lengert. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kILSettingsViewControllerAutoLogin @"auto_login"
#define kILSettingsViewControllerHostname @"host_name"
#define kILSettingsViewControllerCredentials @"credentials"

@interface ILSettingsViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hostTextfield;
@property (weak, nonatomic) IBOutlet UITextField *jIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextfield;
- (IBAction)clickDone:(id)sender;

@end