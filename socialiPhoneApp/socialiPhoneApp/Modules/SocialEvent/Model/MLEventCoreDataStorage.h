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
 * @param message A XMLElement, that includes at least one specific event type (like PLComment)
 * @param moc The managed object context to store the new objects into
 * @param stamp For now the time is not an attribute of our event. So we have to add it from this parameter.
 */
+ (void)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSString *)stamp;
@end
