//
//  MLEventCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MLEventCoreDataStorageObject, MLModuleDataCoreDataStorageObject, MLUserCoreDataStorageObject;

@interface MLEventCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSDate * stamp;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) MLUserCoreDataStorageObject *from;
@property (nonatomic, retain) MLModuleDataCoreDataStorageObject *moduleData;
@property (nonatomic, retain) MLEventCoreDataStorageObject *parent;
@property (nonatomic, retain) NSSet *receiver;
@end

@interface MLEventCoreDataStorageObject (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(MLEventCoreDataStorageObject *)value;
- (void)removeChildrenObject:(MLEventCoreDataStorageObject *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

- (void)addReceiverObject:(MLUserCoreDataStorageObject *)value;
- (void)removeReceiverObject:(MLUserCoreDataStorageObject *)value;
- (void)addReceiver:(NSSet *)values;
- (void)removeReceiver:(NSSet *)values;

@end
