//
//  CLRosterController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 04.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoster.h"

@interface CLRosterController : NSObject <XMPPRosterDelegate, UIAlertViewDelegate>


/**
 * Use this Method to initialize the module and activate it for the given stream.
 * @param stream The XMPP Stream. Must not be NULL, or the module won't work.
 */
- (id)initWithStream:(XMPPStream *)stream;

/**
 * This will deactivate the module and free all resources.
 */
- (void)teardownStream;

/**
 * Returns the Managed Object Context which is used by the roster module.
 */
- (NSManagedObjectContext *)managedObjectContext;


// make init unavailable (throw compiler error)
- (id) init __attribute__((unavailable("Must use initWithStream: instead.")));
@end
