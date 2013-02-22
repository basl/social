//
//  CLModuleController.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "CLModuleController.h"
#import "XMPPFramework.h"
#import "MLEventCoreDataStorage.h"
#import "MLEventCoreDataStorageObject.h"
#import "XMPPMessage+MLEvent.h"
#import "PLEvent.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface CLModuleController ()

@property (strong, nonatomic) MLEventCoreDataStorage *storage;
@end

@implementation CLModuleController {}

/////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PUBLIC METHODS
/////////////////////////////////////////////////////////////////////////////////////////

#pragma mark Singleton

+ (CLModuleController *)sharedInstance {
    static CLModuleController *myInstance = nil;
    
    if (!myInstance) {
        MLEventCoreDataStorage *eventStorage = [[MLEventCoreDataStorage alloc] initWithDatabaseFilename:nil];
        myInstance = [[CLModuleController alloc] initWithEventStorage:eventStorage dispatchQueue:dispatch_get_main_queue()];
    }
    return myInstance;
}

#pragma mark -

- (void)sendEvent:(PLEvent *)event toUser:(NSArray *)jids
{
    //---
    //TODO: handle adding own user of created events another way
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
    
    XMPPMessage *msg2 = [[XMPPMessage alloc] init];
    [msg2 addAttributeWithName:@"to" stringValue:[[self.xmppStream myJID] bare]];
    [msg2 addChild:[event1 copy]];
    [self.xmppStream sendElement:msg2];
}

/////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PRIVATE METHODS
/////////////////////////////////////////////////////////////////////////////////////////


- (id)initWithEventStorage:(MLEventCoreDataStorage *)storage dispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        self.storage = storage;
    }
    return self;
}

#pragma mark - XMPPStream Delegate

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	// This method is invoked on the moduleQueue.
	if (![message hasValidEvents]) {
        return;
    }
    
    // Save events
    [MLEventCoreDataStorage insertEventsInMessage:message managedObjectContext:[self.storage mainThreadManagedObjectContext] forTimeStamp:[NSDate date]];
    
    NSError *err;
    [[self.storage mainThreadManagedObjectContext] save:&err];
    if (err)
    {
        DDLogError(@"Error saving Events: %@", [err userInfo]);
    }
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
	return [self.storage mainThreadManagedObjectContext];
}

@end


