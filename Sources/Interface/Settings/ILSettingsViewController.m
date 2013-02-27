//
//  ILSettingsViewController.m
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 Bastian Lengert. All rights reserved.
//

#import "ILSettingsViewController.h"
#import "CLXMPPController.h"
#import "ILRosterViewController.h"
#import "KeychainItemWrapper.h"
#import "PreferencesController.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ILSettingsViewController ()

@end

@implementation ILSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *retHostName = [PreferencesController getStringPrefForName:kILSettingsViewControllerHostname];
    self.hostTextfield.text = retHostName;
    
    KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:kILSettingsViewControllerCredentials accessGroup:nil];
    NSString *retJID = [keychainPassword objectForKey:(__bridge id)kSecAttrAccount];
    NSString *retPassword = [keychainPassword objectForKey:(__bridge id)kSecValueData];
    self.jIDTextfield.text = retJID;
    self.pwdTextfield.text = retPassword;
    
    //[self loginWithJabberId:self.jIDTextfield.text withPassword:self.pwdTextfield.text forHost:self.hostTextfield.text];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)loginWithJabberId:(NSString *)jid withPassword:(NSString *)password forHost:(NSString *)host
{
    CLXMPPController *xmppController = [CLXMPPController sharedInstance];
    //TODO: check for correct jid and valid host
    [xmppController setHost:host];
    [xmppController setJabberID:jid];
    [xmppController setPassword:password];
    if ([xmppController connect])
    {
        //TODO: if the settingsview is loadid as a modalview
        // then we should dismiss it and show the connectionstate somewhere
        //ILRosterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ILRosterViewController"];

        //[self.navigationController pushViewController:controller animated:YES];
        [self.delegate connectionSuccessfull];
    }
    else
    {
        //TODO: Handle connection error
    }
}

#pragma mark - UI Methods

- (IBAction)clickDone:(id)sender
{
    [PreferencesController setStringPref:self.hostTextfield.text forKey:kILSettingsViewControllerHostname];
    
    KeychainItemWrapper *keychainPassword = [[KeychainItemWrapper alloc] initWithIdentifier:kILSettingsViewControllerCredentials accessGroup:nil];
    [keychainPassword setObject:self.jIDTextfield.text forKey:(__bridge id)kSecAttrAccount];
    [keychainPassword setObject:self.pwdTextfield.text forKey:(__bridge id)kSecValueData];
    
    [self loginWithJabberId:self.jIDTextfield.text withPassword:self.pwdTextfield.text forHost:self.hostTextfield.text];
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
        [self loginWithJabberId:self.jIDTextfield.text withPassword:self.pwdTextfield.text forHost:self.hostTextfield.text];
	}
	return YES;
}
@end
