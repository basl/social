//
//  AppDelegate.m
//  socialiPhoneApp
//
//  Created by Bastian Lengert on 21.04.12.
//  Copyright (c) 2012 Bastian Lengert. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"

#import "PreferencesController.h"
#import "KeychainItemWrapper.h"
#import "ILSettingsViewController.h"
#import "CLXMPPController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
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
        ILSettingsViewController *settingsViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ILSettingsViewController"];
        //TODO: Better load it as a modalview?
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        [self.window makeKeyAndVisible];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
