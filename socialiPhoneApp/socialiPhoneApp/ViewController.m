//
//  ViewController.m
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 greenbytes GmbH. All rights reserved.
//

#import "ViewController.h"
#import "SOXMPPController.h"
#import "SORosterViewController.h"
#import "KeychainItemWrapper.h"
#import "PreferencesController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL autoLog = [[PreferencesController getBoolPrefForName:CFSTR("autoLogin")] boolValue];
    [self.autoLoginSwitch setOn:autoLog];
    
    if (autoLog)
    {
        KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:@"credentials" accessGroup:nil];
        NSString *retPassword = [keychainPassword objectForKey:(__bridge id)kSecValueData];
        NSString *retUser = [keychainPassword objectForKey:(__bridge id)kSecAttrAccount];
        [self.jIDTextfield setText:retUser];
        [self.pwdTextfield setText:retPassword];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)done
{
    SOXMPPController *xmppController = [SOXMPPController sharedInstance];
    //TODO: check for correct jid and valid host
    [xmppController setHost:self.hostTextfield.text];
    [xmppController setJabberID:self.jIDTextfield.text];
    [xmppController setPassword:self.pwdTextfield.text];
    if ([xmppController connect])
    {
        SORosterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SORosterViewController"];

        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UI Methods

- (IBAction)clickDone:(id)sender
{
    if ([self.autoLoginSwitch isOn])
    {
        KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:@"credentials" accessGroup:nil];
        [keychainPassword setObject:[self.pwdTextfield text] forKey:(__bridge id)kSecValueData];
        [keychainPassword setObject:[self.jIDTextfield text] forKey:(__bridge id)kSecAttrAccount];
    }
    
    [self done];
}

- (IBAction)changeAutoLogin:(UISwitch *)sender {
    [PreferencesController setBoolPref:[self.autoLoginSwitch isOn] forKey:CFSTR("autoLogin")];
}


#pragma mark - UITextfieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.hostTextfield) {
		[textField resignFirstResponder];
		[self.jIDTextfield becomeFirstResponder];
	}
	else if (textField == self.jIDTextfield) {
		[textField resignFirstResponder];
		[self.pwdTextfield becomeFirstResponder];
	}
	else if (textField == self.pwdTextfield) {
		[textField resignFirstResponder];
        [self done];
	}
	return YES;
}
@end
