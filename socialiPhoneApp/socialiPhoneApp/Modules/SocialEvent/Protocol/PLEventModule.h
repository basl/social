//
//  PLEventModule.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "XMPPModule.h"
#import "MLEventCoreDataStorage.h"

@interface PLEventModule : XMPPModule

- (id)initWithEventStorage:(MLEventCoreDataStorage *)storage dispatchQueue:(dispatch_queue_t)queue;

// make init unavailable (throw compiler error)
- (id) init __attribute__((unavailable("Must use initWithEventStorage:dispatchQueue: instead.")));

- (NSManagedObjectContext *)managedObjectContext;
@end
