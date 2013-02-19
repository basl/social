//
//  CLXMPPController.m
//  socialiPhoneApp
//
//  Created by David Donszik on 21.01.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "CLXMPPController.h"
#import "XMPPFramework.h"
#import "CLRosterController.h"
#import "SOLogging.h"
#import "PLEvent.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface CLXMPPController ()
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;

@property BOOL allowSelfSignedCertificates;
@property BOOL allowSSLHostNameMismatch;
@property BOOL isXmppConnected;
@end

@implementation CLXMPPController


#pragma mark Singleton

+ (CLXMPPController *)sharedInstance {
    static CLXMPPController *myInstance = nil;
    
    if (!myInstance) {
        myInstance = [[CLXMPPController alloc] init];
    }
    return myInstance;
}

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        [self setupStream];
    }
    return self;
}

- (void)dealloc
{
	[self teardownStream];
}

- (void)setupStream
{
	NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
	DDLogVerbose(@"Setting up Stream");
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	_xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		self.xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	_xmppReconnect = [[XMPPReconnect alloc] init];
	
	
    // Setup roster
    _rosterController = [[CLRosterController alloc] initWithStream:self.xmppStream];
    
    // Setup EventModule
    MLEventCoreDataStorage *eventStorage = [[MLEventCoreDataStorage alloc] initWithDatabaseFilename:nil];
    _eventModule = [[PLEventModule alloc] initWithEventStorage:eventStorage dispatchQueue:dispatch_get_main_queue()];
    
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
    /*
     xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
     xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
     
     xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
     */
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
    /*
     xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
     xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
     
     xmppCapabilities.autoFetchHashedCapabilities = YES;
     xmppCapabilities.autoFetchNonHashedCapabilities = NO;
     */
    
	// Activate xmpp modules
    
	[self.xmppReconnect     activate:self.xmppStream];
    [self.eventModule       activate:self.xmppStream];
     /*[xmppvCardTempModule   activate:xmppStream];
     [xmppvCardAvatarModule activate:xmppStream];
     [xmppCapabilities      activate:xmppStream];*/
    
	// Add ourself as a delegate to anything we may be interested in
    
	[self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	self.allowSelfSignedCertificates = YES;
	self.allowSSLHostNameMismatch = YES;
}

- (void)teardownStream
{
	[self.xmppStream removeDelegate:self];
    
    [self.rosterController teardownStream];
	[self.xmppReconnect         deactivate];
    [self.eventModule           deactivate];
    
	[self.xmppStream disconnect];
	
	_xmppStream = nil;
	_xmppReconnect = nil;
    _eventModule = nil;
}


- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[self.xmppStream sendElement:presence];
    
    DDLogVerbose(@"Going online");
}

- (void)sendEvent:(PLEvent *)event toUser:(NSArray *)jids
{
    //---
    //TODO: handle adding own user of created events otherwise
    // adding self as recipient to get the event
    XMPPJID *ownJID = self.xmppStream.myJID;
    NSMutableArray *mutJIDs = [NSMutableArray arrayWithArray:jids];
    BOOL selfIncluded = NO;
    
    for (XMPPJID *jid in jids) {
        
        if ([[ownJID bare] isEqualToString:[jid bare]]) {
            selfIncluded = YES;
            break;
        }
    }
    if (!selfIncluded) {
        [mutJIDs addObject:ownJID];
    }
    //---
    
    event.from = self.xmppStream.myJID;
    for (XMPPJID *jid in mutJIDs) {
        
        XMPPMessage *msg = [[XMPPMessage alloc] init];
        [msg addAttributeWithName:@"to" stringValue:[jid bare]];
        
        [msg addChild:[event copy]];
        
        [self.xmppStream sendElement:msg];
    }
}

//TODO: remove - testing
- (void)sendEventToUser:(NSString *)jid
{
    
    XMPPMessage *msg = [[XMPPMessage alloc] init];
    [msg addAttributeWithName:@"to" stringValue:jid];
    
    // Event 1
    PLEvent *event1 = [PLEvent eventWithParent:nil
                                          from:[self.xmppStream myJID]
                                            to:@[[XMPPJID jidWithString:jid]]];
    
    
    NSXMLElement *body = [[NSXMLElement alloc] initWithName:@"body"];
    [body setStringValue:@"Erstens!"];
    
    NSXMLElement *comment = [[NSXMLElement alloc] initWithName:@"comment"];
    [comment addChild:body];
    [event1 setData:comment];
    
    
    [msg addChild:event1];
    [self.xmppStream sendElement:msg];
    
    // send again to self
    //TODO: remove this test
    
    XMPPMessage *msg2 = [[XMPPMessage alloc] init];
    [msg2 addAttributeWithName:@"to" stringValue:[[self.xmppStream myJID] bare]];
    [msg2 addChild:[event1 copy]];
    [self.xmppStream sendElement:msg2];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PUBLIC METHODS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![self.xmppStream isDisconnected])
    {
		return YES;
	}
	
	if (self.jabberID == nil || self.password == nil)
    {
		return NO;
	}
    
	[self.xmppStream setMyJID:[XMPPJID jidWithString:self.jabberID]];
    
    if (self.host != nil)
    {
        [self.xmppStream setHostName:self.host];
    }
    
	NSError *error = nil;
	if (![self.xmppStream connect:&error])
	{
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
	return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (self.allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (self.allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	self.isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
	if ([message isChatMessageWithBody])
	{
		DDLogVerbose(@"%@", [message stringValue]);
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!self.isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Error: %@", [error userInfo]);
	}
}

@end
