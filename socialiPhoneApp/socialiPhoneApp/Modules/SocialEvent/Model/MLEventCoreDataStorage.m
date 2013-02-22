//
//  MLEventCoreDataStorage.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "MLEventCoreDataStorage.h"
#import "XMPPFramework.h"
#import "MLEventCoreDataStorageObject.h"
#import "MLCommentCoreDataStorageObject.h"
#import "MLImageCoreDataStorageObject.h"
#import "MLUserCoreDataStorageObject.h"
#import "XMPPMessage+MLEvent.h"
#import "PLEvent.h"
#import "PLComment.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

//TODO: extract into modules, let a factory create the events
static NSString *const IMAGE = @"image";
static NSString *const COMMENT = @"comment";


@implementation MLEventCoreDataStorage

//TODO: let factories create and store specific events - move this to CL
+ (void)insertEventsInMessage:(XMPPMessage *)message
              managedObjectContext:(NSManagedObjectContext *)moc
                      forTimeStamp:(NSDate *)stamp
{
    if (moc == nil)
    {
        DDLogWarn(@"No ManagedObjectContext given to save events into.");
        return;
    }
    
    if (stamp == nil)
    {
        DDLogWarn(@"Can not create event without timestamp.");
        return;
    }
    
    if (![message hasValidEvents])
    {
        DDLogWarn(@"Message has no valid events.");
        return;
    }
    
	NSString *eventClassName    = NSStringFromClass([MLEventCoreDataStorageObject class]);
	NSString *commentClassName  = NSStringFromClass([MLCommentCoreDataStorageObject class]);
    NSString *imageClassName    = NSStringFromClass([MLImageCoreDataStorageObject class]);
    
    MLEventCoreDataStorageObject *newEvent;
    MLModuleDataCoreDataStorageObject *moduleData;
    MLCommentCoreDataStorageObject *commentModuleData;
    MLImageCoreDataStorageObject *imageModuleData;
    
    
    NSArray *events = [message getValidEvents];
    
    NSString *eventId;
    MLUserCoreDataStorageObject *fromUser;
    MLUserCoreDataStorageObject *toUser;
    NSMutableSet *recipients = [NSMutableSet set];
    
    for (NSXMLElement *eventXML in events) {
        
        PLEvent *event = [PLEvent eventFromElement:eventXML];
        
        eventId = event.eventId;
        
        // Parent ID is optional, but if its present, then the parent MUST be available
        MLEventCoreDataStorageObject *parent;
        NSString *parentId = event.parentId;
        if (parentId != nil) {
            parent = [MLEventCoreDataStorage eventForID:parentId managedObjectContext:moc];
            if (parent == nil)
            {
                DDLogError(@"Structural Error: Parent of event not persisted. Discarding Event.");
                break;
            }
        }
        
        NSString *fromStr = [event.from bare];
        fromUser = [MLEventCoreDataStorage getOrCreateUserForBareJID:fromStr managedObjectContext:moc];
        if (fromUser == nil)
        {
            DDLogError(@"Structural Error: Could not load or create user. Discarding Event.");
            break;
        }
        
        for (XMPPJID *recipient in event.recipients) {
            toUser = [MLEventCoreDataStorage getOrCreateUserForBareJID:[recipient bare] managedObjectContext:moc];
            if (toUser == nil)
            {
                DDLogError(@"Structural Error: Could not load or create user. Discarding Event.");
                break;
            }
            [recipients addObject:toUser];
        }
        
        
        
        newEvent = [NSEntityDescription insertNewObjectForEntityForName:eventClassName
                                                 inManagedObjectContext:moc];
        newEvent.eventId = eventId;
        newEvent.stamp = stamp;
        newEvent.parent = parent;
        newEvent.from = fromUser;
        [newEvent addReceiver:recipients];
        
        //TODO: the following is just a test! Implement Factory to create ModuleData from valid NSXMLElement
        if ([PLComment isComment:event]) {
            PLComment *comment = [PLComment commentFromEvent:event];
            
            commentModuleData = [NSEntityDescription insertNewObjectForEntityForName:commentClassName
                                                              inManagedObjectContext:moc];
            //TODO: read moduleName from element
            commentModuleData.moduleName = COMMENT;
            commentModuleData.body = comment.body;
            moduleData = commentModuleData;
        }
        else if ([event elementForName:IMAGE] != nil)
        {
            //NSXMLElement *child = [event elementForName:IMAGE];
            
            imageModuleData = [NSEntityDescription insertNewObjectForEntityForName:imageClassName
                                                            inManagedObjectContext:moc];
            imageModuleData.moduleName = IMAGE;
            imageModuleData.imageData = @"(*)(*)";
            moduleData = imageModuleData;
        }
        newEvent.moduleData = moduleData;
    }
}

+ (MLUserCoreDataStorageObject *)userForJID:(XMPPJID *)jid
                       managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
	NSString *bareJIDStr = [jid bare];
	return [self userForBareJID:bareJIDStr managedObjectContext:moc];
}

+ (MLUserCoreDataStorageObject *)userForBareJID:(NSString *)jid
                           managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
	if (moc == nil) return nil;
	
	NSString *userClassName  = NSStringFromClass([MLUserCoreDataStorageObject class]);
	NSEntityDescription *entity = [NSEntityDescription entityForName:userClassName
	                                          inManagedObjectContext:moc];
	
	NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"jid == %@", jid];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPendingChanges:YES];
	[fetchRequest setFetchLimit:1];
	
	NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
	
	return (MLUserCoreDataStorageObject *)[results lastObject];
}

+ (MLUserCoreDataStorageObject *)getOrCreateUserForBareJID:(NSString *)jid
                                      managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
    MLUserCoreDataStorageObject *user = [MLEventCoreDataStorage userForBareJID:jid
                                                          managedObjectContext:moc];
    if (user == nil) {
        NSString *userClassName  = NSStringFromClass([MLUserCoreDataStorageObject class]);
        user = [NSEntityDescription insertNewObjectForEntityForName:userClassName
                                             inManagedObjectContext:moc];
        user.jid = jid;
    }
    return user;
}

+ (MLEventCoreDataStorageObject *)eventForID:(NSString *)eventId
                        managedObjectContext:(NSManagedObjectContext *)moc
{
    if (eventId == nil) return nil;
	if (moc == nil)     return nil;
	
	NSString *eventClassName  = NSStringFromClass([MLEventCoreDataStorageObject class]);
	NSEntityDescription *entity = [NSEntityDescription entityForName:eventClassName
	                                          inManagedObjectContext:moc];
	
	NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventId];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPendingChanges:YES];
	[fetchRequest setFetchLimit:1];
	
	NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
	
	return (MLEventCoreDataStorageObject *)[results lastObject];
}
@end










