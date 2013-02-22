//
//  MLModuleDataProtocol.h
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLModuleDataCoreDataStorageObject.h"
#import "PLEvent.h"

@protocol MLModuleDataProtocol <NSObject>

+ (MLModuleDataCoreDataStorageObject *)createModuleDataForEvent:(PLEvent *)event
                                           managedObjectContext:(NSManagedObjectContext *)moc;
@end
