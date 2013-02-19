//
//  PLEventModule.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLEventModule.h"
#import "XMPPFramework.h"
#import "MLEventCoreDataStorageObject.h"
#import "XMPPMessage+MLEvent.h"
#import "SOLogging.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface PLEventModule ()
@property (strong, nonatomic) MLEventCoreDataStorage *storage;
@end

@implementation PLEventModule


- (id)initWithEventStorage:(MLEventCoreDataStorage *)storage dispatchQueue:(dispatch_queue_t)queue
{
    self = [super initWithDispatchQueue:queue];
    if (self) {
        self.storage = storage;
    }
    return self;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	// This method is invoked on the moduleQueue.
	if (![message hasValidEvents]) {
        return;
    }
    
    // Save events
    //TODO: let factories create and store specific events - move this to CL
    NSArray *events = [MLEventCoreDataStorage insertEventsInMessage:message managedObjectContext:[self.storage mainThreadManagedObjectContext] forTimeStamp:[NSDate date]];
    
    DDLogVerbose(@"Persisted Events: %d", [events count]);
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


