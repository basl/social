//
//  ViewController.m
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 greenbytes GmbH. All rights reserved.
//

#import "ViewController.h"
#import "SOXMPPController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [xmppController connect];
}

#pragma mark - UI Methods

- (IBAction)clickDone:(id)sender
{
    [self done];
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
