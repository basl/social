//
//  MLModuleDataCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MLEventCoreDataStorageObject;

@interface MLModuleDataCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * moduleName;
@property (nonatomic, retain) MLEventCoreDataStorageObject *event;

@end
