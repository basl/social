//
//  ViewController.h
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 greenbytes GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hostTextfield;
@property (weak, nonatomic) IBOutlet UITextField *jIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *autoLoginSwitch;
- (IBAction)clickDone:(id)sender;
- (IBAction)changeAutoLogin:(UISwitch *)sender;

@end