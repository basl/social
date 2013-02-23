//
//  MLEventCoreDataStorage.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "XMPPCoreDataStorage.h"

@class XMPPMessage;

/**
 * This class persists events and delegates persisting specific module data to factories.
 * The Factories to create the MLModuleDataCoreDataStorageObject follow these naming conventions:
 *
 * ML*Type*CoreDataStorageObject e.g.: MLCommentCoreDataStorageObject
 *
 * The *Type* MUST have a capital letter and the rest MUST be lowercase.
 * The Type will be extracted from the element name of the specific event and transformed 
 * to that needs.
 */
@interface MLEventCoreDataStorage : XMPPCoreDataStorage
/**
 * Will try to save the contents of the message into the given context.
 *
 * If the parentId is set, but not persistet, then (for now) the event will be discarded.
 * Later on we will implement functionality to react accordingly.
 *
 * @param message A XMLElement, that includes at least one specific event type (like PLComment)
 * @param moc The managed object context to store the new objects into
 * @param stamp For now the time is not an attribute of our event. So we have to add it from this parameter.
 */
+ (void)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSString *)stamp;
@end
