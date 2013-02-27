//
//  MLImageCoreDataStorageObject+Factory.m
//  Social
//
//  Created by David Donszik on 23.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "MLImageCoreDataStorageObject+Factory.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation MLImageCoreDataStorageObject (Factory)

+ (MLModuleDataCoreDataStorageObject *)createModuleDataForEvent:(PLEvent *)event
                                           managedObjectContext:(NSManagedObjectContext *)moc
{
    DDLogWarn(@"Persisting Images is not implemented yet.");
    return nil;
}
@end
