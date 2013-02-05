//
//  CLRosterController.m
//  socialiPhoneApp
//
//  Created by David Donszik on 04.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "CLRosterController.h"
#import "XMPPFramework.h"
#import "SOLogging.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface CLRosterController ()
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, weak, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPJID *requestJID;
@end

@implementation CLRosterController

- (id)initWithStream:(XMPPStream *)stream
{
    NSAssert(stream != nil, @"Can not initialize Roster Controller without a stream");
    self = [super init];
    if (self) {
        _xmppStream = stream;
        _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
        
        // Customization
        self.xmppRoster.autoFetchRoster = YES;
        self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
        
        [self.xmppRoster activate:self.xmppStream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)teardownStream
{
	[self.xmppRoster removeDelegate:self];
	[self.xmppRoster deactivate];
    _xmppRoster = nil;
	_xmppRosterStorage = nil;
    _xmppStream = nil;
}

- (void)dealloc
{
    [self teardownStream];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext
{
	return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[presence from]
                                                                  xmppStream:self.xmppStream
                                                        managedObjectContext:[self managedObjectContext]];
    if (self.requestJID != nil)
    {
        //TODO: Allow more then one request at a time. 
        DDLogWarn(@"Oh, we can only handle one request at a time for now. :-(");
        return;
    }
    self.requestJID = [presence from];
    DDLogInfo(@"Request from JID: %@", self.requestJID);
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	NSString *bodyPre = NSLocalizedString(@"Buddy request from", @"Alertview body for adding a buddy");
    
	if (![displayName isEqualToString:jidStrBare] && displayName != nil)
	{
		body = [NSString stringWithFormat:@"%@ %@ <%@>", bodyPre, displayName, jidStrBare];
	}
	else if (displayName != nil)
	{
		body = [NSString stringWithFormat:@"%@ %@", bodyPre, displayName];
	}
    else
    {
        body = [NSString stringWithFormat:@"%@ %@", bodyPre, jidStrBare];
    }
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:NSLocalizedString(@"Decline", @"Button text to cancel buddy request")
		                                          otherButtonTitles:NSLocalizedString(@"Accept", @"Button text to accept buddy request"), nil];
        [alertView setDelegate:self];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        DDLogInfo(@"Reject Subscription from: %@", self.requestJID);
        // Button Index 0: Decline
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.requestJID];
    }
    else
    {
        DDLogInfo(@"Accept and add Subscription from: %@", self.requestJID);
        // Button Index 1: Accept
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.requestJID andAddToRoster:YES];
    }
    
    
    self.requestJID = nil;
}

@end
