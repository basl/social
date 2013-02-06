//
//  MLImageCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLModuleDataCoreDataStorageObject.h"


@interface MLImageCoreDataStorageObject : MLModuleDataCoreDataStorageObject

@property (nonatomic, retain) id imageData;

@end
