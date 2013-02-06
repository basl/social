//
//  MLEventCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

@class MLModuleDataCoreDataStorageObject;
@class XMPPJID;

@interface MLEventCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * stamp;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) MLModuleDataCoreDataStorageObject *moduleData;


+ (NSArray *)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSString *)stamp;

@end
