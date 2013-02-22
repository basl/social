//
//  MLImageCoreDataStorageObject.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLModuleDataCoreDataStorageObject.h"
#import "MLModuleDataProtocol.h"


@interface MLImageCoreDataStorageObject : MLModuleDataCoreDataStorageObject <MLModuleDataProtocol>

@property (nonatomic, retain) id imageData;

@end
