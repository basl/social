//
//  PLEventModule.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "PLEventModule.h"
#import "XMPPFramework.h"
#import "SOLogging.h"
#import "MLEventCoreDataStorageObject.h"

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
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [message fromStr]);
    
    // Save events
    NSArray *events = [MLEventCoreDataStorageObject insertEventsInMessage:message managedObjectContext:[self.storage mainThreadManagedObjectContext] forTimeStamp:@"2002-09-10T23:41:07Z"];
    
    DDLogVerbose(@"Persisted Events: %@", events);
    NSError *err;
    [[self.storage mainThreadManagedObjectContext] save:&err];
    if (err)
    {
        DDLogError(@"Error saving Events: %@", [err userInfo]);
    }
}

@end


