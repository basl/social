//
//  MLCommentCoreDataStorageObject+Factory.m
//  Social
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "MLCommentCoreDataStorageObject+Factory.h"
#import "PLComment.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation MLCommentCoreDataStorageObject (Factory)

+ (MLModuleDataCoreDataStorageObject *)createModuleDataForEvent:(PLEvent *)event
                                           managedObjectContext:(NSManagedObjectContext *)moc
{
    if (![PLComment isComment:event])
    {
        DDLogWarn(@"The event is not a comment.");
        return nil;
    }
    
    PLComment *comment = [PLComment commentFromEvent:event];
    
    NSString *commentClassName  = NSStringFromClass([MLCommentCoreDataStorageObject class]);
    
    MLCommentCoreDataStorageObject *commentModuleData = [NSEntityDescription insertNewObjectForEntityForName:commentClassName
                                                                                      inManagedObjectContext:moc];
    commentModuleData.moduleName = comment.type;
    commentModuleData.body = comment.body;
    
    return commentModuleData;
}

@end
