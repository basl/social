//
//  MLEventCoreDataStorageObject.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "MLEventCoreDataStorageObject.h"
#import "MLCommentCoreDataStorageObject.h"
#import "MLImageCoreDataStorageObject.h"
#import "XMPPFramework.h"
#import "XMPPMessage+MLEvent.h"
#import "SOLogging.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@implementation MLEventCoreDataStorageObject

@dynamic eventId;
@dynamic parentId;
@dynamic stamp;
@dynamic jid;
@dynamic moduleData;

+ (NSArray *)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSString *)stamp
{
    if (moc == nil)
    {
        DDLogWarn(@"No ManagedObjectContext given to save events into.");
        return nil;
    }
    if (stamp == nil)
    {
        DDLogWarn(@"Can not create event without timestamp.");
        return nil;
    }
    if (![message hasValidEvents])
    {
        DDLogWarn(@"Message has no valid events.");
        return nil;
    }
    
    NSString *from = [message fromStr];
	NSString *eventClassName = NSStringFromClass([MLEventCoreDataStorageObject class]);
	NSString *commentClassName = NSStringFromClass([MLCommentCoreDataStorageObject class]);
    NSString *imageClassName = NSStringFromClass([MLImageCoreDataStorageObject class]);
    
    
    NSArray *events = [message getValidEvents];
    NSMutableArray *persistedEvents = [[NSMutableArray alloc] initWithCapacity:[events count]];
    MLEventCoreDataStorageObject *newEvent;
    MLModuleDataCoreDataStorageObject *moduleData;
    MLCommentCoreDataStorageObject *commentModuleData;
    MLImageCoreDataStorageObject *imageModuleData;
    
    int i = 0;
    for (NSXMLElement *event in events) {
        newEvent = [NSEntityDescription insertNewObjectForEntityForName:eventClassName
                                                 inManagedObjectContext:moc];
        newEvent.eventId = [[event attributeForName:@"eventId"] stringValue];
        NSXMLNode *parentIdNode = [event attributeForName:@"parentId"];
        if (parentIdNode != nil)
        {
            newEvent.parentId = [parentIdNode stringValue];
        }
        newEvent.stamp = stamp;
        newEvent.jid = from;
        
        if (i == 0)
        {
            //TODO: just to test! Implement Factory to create ModuleData from NSXMLElement
            commentModuleData = [NSEntityDescription insertNewObjectForEntityForName:commentClassName
                                                       inManagedObjectContext:moc];
            commentModuleData.moduleName = @"comment";
            commentModuleData.body = @"FIRST!";
            moduleData = commentModuleData;
        }
        else
        {
            DDLogVerbose(@"Logging IMAGE");
            imageModuleData = [NSEntityDescription insertNewObjectForEntityForName:imageClassName
                                                       inManagedObjectContext:moc];
            imageModuleData.moduleName = @"image";
            imageModuleData.imageData = @"(*)(*)";
            moduleData = imageModuleData;
        }
        newEvent.moduleData = moduleData;
        
        [persistedEvents addObject:newEvent];
        i ++;
    }
    
    return persistedEvents;
}


@end
