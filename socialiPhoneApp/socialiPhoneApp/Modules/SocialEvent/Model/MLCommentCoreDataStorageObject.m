//
//  MLCommentCoreDataStorageObject.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "MLCommentCoreDataStorageObject.h"
#import "PLComment.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation MLCommentCoreDataStorageObject

@dynamic body;

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
