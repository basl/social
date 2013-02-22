//
//  MLImageCoreDataStorageObject.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "MLImageCoreDataStorageObject.h"
#import "PLComment.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation MLImageCoreDataStorageObject

@dynamic imageData;

+ (MLModuleDataCoreDataStorageObject *)createModuleDataForEvent:(PLEvent *)event
                                           managedObjectContext:(NSManagedObjectContext *)moc
{
    DDLogWarn(@"Persisting Images is not implemented yet.");
    return nil;
}

@end
