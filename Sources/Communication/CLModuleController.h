//
//  CLModuleController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "XMPPModule.h"

@class PLEvent;

/**
 * This Class is used as a singleton. It can be called from all modules to send events.
 * It will dispatch incoming events and forward them to the specific modules.
 */
@interface CLModuleController : XMPPModule

/** 
 * Singleton implementation
 * @return The singleton of this class.
 */
+ (CLModuleController *)sharedInstance;

/** @return The managed object context used by the event modules */
- (NSManagedObjectContext *)managedObjectContext;

/** 
 * Sends an event to users.
 * If own jid is not included in the recipients array, it will be added by this method.
 * @param event The specified PLEvent (like PLComment).
 * @param jids Array of XMPPJID as recipients for this event.
 * This method currently sends every event also to the own user. 
 * This should be changed in the future.
 */
- (void)sendEvent:(PLEvent *)event toUser:(NSArray *)jids;

/**
 * This is just a test. It will get removed soon.
 * Don't use it!
 * @param jid XMPPJID added as recipient
 */
- (void)sendEventToUser:(NSString *)jid; //TODO: remove - testing

/** Make init unavailable (throw compiler error) */
- (id) init __attribute__((unavailable("Must use sharedInstance.")));

@end
