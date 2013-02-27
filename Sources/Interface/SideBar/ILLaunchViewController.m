//
//  ILLaunchViewController.m
//  Social
//
//  Created by Bastian Lengert on 27.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import "ILLaunchViewController.h"

#import "PreferencesController.h"
#import "ILSettingsViewController.h"
#import "KeychainItemWrapper.h"
#import "CLXMPPController.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ILLaunchViewController ()
@property (nonatomic, strong) ILSettingsViewController *settingsViewController;
@end

@implementation ILLaunchViewController

#pragma mark - Init and Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // need to ini the xmpp connection
    [self initXMPP];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // need to ini the xmpp connection
    [self initXMPP];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Application Launch

- (void)initXMPP
{
    NSString *retHostName = [PreferencesController getStringPrefForName:kILSettingsViewControllerHostname];
    
    KeychainItemWrapper *keychainCredentials = [[KeychainItemWrapper alloc] initWithIdentifier:kILSettingsViewControllerCredentials accessGroup:nil];
    NSString *retJID = [keychainCredentials objectForKey:(__bridge id)kSecAttrAccount];
    NSString *retPassword = [keychainCredentials objectForKey:(__bridge id)kSecValueData];
    
    CLXMPPController *xmppController = [CLXMPPController sharedInstance];
    //TODO: check for correct jid and valid host
    [xmppController setHost:retHostName];
    [xmppController setJabberID:retJID];
    [xmppController setPassword:retPassword];
    if (![xmppController connect])
    {
        // error accured! Warn User and provide option to change settings
        UINavigationController *settingsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"ILSettingsNavigationViewController"];

        self.settingsViewController = (ILSettingsViewController *)[settingsNavigationController topViewController];
        if (![self.settingsViewController isKindOfClass:[ILSettingsViewController class]]) {
            DDLogError(@"Expected ILSettingsViewController as topViewController of UINavigationController!");
            self.settingsViewController = nil;
        }
        self.settingsViewController.warningLabel.hidden = NO;
        self.settingsViewController.delegate = self;
        [self presentViewController:settingsNavigationController animated:YES completion:nil];
    }
}

#pragma mark - ILSettingsViewControllerDelegate

- (void)connectionSuccessfull
{
    [self.settingsViewController.navigationController dismissViewControllerAnimated:YES completion:^{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success"
                                                          message:@"You are now connected."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }];
}

@end
