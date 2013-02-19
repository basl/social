//
//  MLUserCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MLEventCoreDataStorageObject;

@interface MLUserCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSSet *receivesEvent;
@property (nonatomic, retain) NSSet *sendsEvent;
@end

@interface MLUserCoreDataStorageObject (CoreDataGeneratedAccessors)

- (void)addReceivesEventObject:(MLEventCoreDataStorageObject *)value;
- (void)removeReceivesEventObject:(MLEventCoreDataStorageObject *)value;
- (void)addReceivesEvent:(NSSet *)values;
- (void)removeReceivesEvent:(NSSet *)values;

- (void)addSendsEventObject:(MLEventCoreDataStorageObject *)value;
- (void)removeSendsEventObject:(MLEventCoreDataStorageObject *)value;
- (void)addSendsEvent:(NSSet *)values;
- (void)removeSendsEvent:(NSSet *)values;

@end
