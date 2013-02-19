//
//  MLEventCoreDataStorage.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "XMPPCoreDataStorage.h"

@class XMPPMessage;

@interface MLEventCoreDataStorage : XMPPCoreDataStorage
/**
 * Will try to save the contents of the message into the given context.
 */
+ (NSArray *)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSString *)stamp;
@end
