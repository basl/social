//
//  ILSettingsViewController.m
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 greenbytes GmbH. All rights reserved.
//

#import "ILSettingsViewController.h"
#import "CLXMPPController.h"
#import "ILRosterViewController.h"
#import "KeychainItemWrapper.h"
#import "PreferencesController.h"
#import "SOLogging.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

static NSString *AUTOLOGIN      = @"auto_login";
static NSString *HOSTNAME       = @"host_name";
static NSString *CREDENTIALS    = @"credentials";

@interface ILSettingsViewController ()

@end

@implementation ILSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL autoLog = [PreferencesController getBoolPrefForName:AUTOLOGIN];
    [self.autoLoginSwitch setOn:autoLog];
    
    if (autoLog)
    {
        NSString *retHostName = [PreferencesController getStringPrefForName:HOSTNAME];
        self.hostTextfield.text = retHostName;
        
        KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:CREDENTIALS accessGroup:nil];
        NSString *retJID = [keychainPassword objectForKey:(__bridge id)kSecAttrAccount];
        NSString *retPassword = [keychainPassword objectForKey:(__bridge id)kSecValueData];
        self.jIDTextfield.text = retJID;
        self.pwdTextfield.text = retPassword;
        
        [self login];
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

- (void)login
{
    CLXMPPController *xmppController = [CLXMPPController sharedInstance];
    //TODO: check for correct jid and valid host
    [xmppController setHost:self.hostTextfield.text];
    [xmppController setJabberID:self.jIDTextfield.text];
    [xmppController setPassword:self.pwdTextfield.text];
    if ([xmppController connect])
    {
        ILRosterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ILRosterViewController"];

        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        //TODO: Handle connection error
    }
}

#pragma mark - UI Methods

- (IBAction)clickDone:(id)sender
{
    if ([self.autoLoginSwitch isOn])
    {
        [PreferencesController setBoolPref:[self.autoLoginSwitch isOn] forKey:AUTOLOGIN];
        [PreferencesController setStringPref:self.hostTextfield.text forKey:HOSTNAME];
        
        KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:CREDENTIALS accessGroup:nil];
        [keychainPassword setObject:self.jIDTextfield.text forKey:(__bridge id)kSecAttrAccount];
        [keychainPassword setObject:self.pwdTextfield.text forKey:(__bridge id)kSecValueData];
    }
    
    [self login];
}

- (IBAction)changeAutoLogin:(UISwitch *)sender {
    [PreferencesController setBoolPref:[self.autoLoginSwitch isOn] forKey:AUTOLOGIN];
    //TODO: Update (or delete) Credentials
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
        [self login];
	}
	return YES;
}
@end
