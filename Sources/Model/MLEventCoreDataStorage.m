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
#import "MLUserCoreDataStorageObject.h"
#import "XMPPMessage+MLEvent.h"
#import "PLEvent.h"
#import "NSString+FirstCapitalized.h"
#import "MLModuleDataProtocol.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation MLEventCoreDataStorage {}

//---------------------------------------------------------------------------------------
#pragma mark - PUBLIC METHODS
//---------------------------------------------------------------------------------------

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
        
        // Check for the correct Module to create the ModuleDataObject
        NSString * moduleName = event.type;
        if (!moduleName) {
            DDLogWarn(@"Could not determine type of event.");
            break;
        }
        // The Factories to create the MLModuleDataCoreDataStorageObject follow these naming conventions:
        // ML<Type>CoreDataStorageObject e.g.: MLCommentCoreDataStorageObject
        // The Type MUST have a capital letter and the rest MUST be lowercase.
        
        moduleName = [moduleName firstCapRestLow];
        if (!moduleName)
        {
            DDLogWarn(@"Module type could not be extracted from event.");
            break;
        }
        moduleName = [NSString stringWithFormat:@"ML%@CoreDataStorageObject", moduleName];
        
        DDLogVerbose(@"Trying to load moduledata from %@.", moduleName);
        
        Class moduleDataStorage = NSClassFromString(moduleName);
        
        MLModuleDataCoreDataStorageObject *moduleData;
        if ([moduleDataStorage conformsToProtocol:@protocol(MLModuleDataProtocol)])
        {
            Class<MLModuleDataProtocol> moduleClass = moduleDataStorage;
            moduleData = [moduleClass createModuleDataForEvent:event
                                          managedObjectContext:moc];
        }
        if (!moduleData) {
            DDLogWarn(@"Could not create moduledata.");
            break;
        }
        
        
        NSString *eventClassName    = NSStringFromClass([MLEventCoreDataStorageObject class]);
        MLEventCoreDataStorageObject *newEvent = [NSEntityDescription insertNewObjectForEntityForName:eventClassName
                                                                               inManagedObjectContext:moc];
        newEvent.eventId = eventId;
        newEvent.stamp = stamp;
        newEvent.parent = parent;
        newEvent.from = fromUser;
        [newEvent addReceiver:recipients];
        
        //TODO: the following is just a test! Implement Factory to create ModuleData from valid NSXMLElement
        
        newEvent.moduleData = moduleData;
    }
}


//---------------------------------------------------------------------------------------
#pragma mark - PRIVATE METHODS
//---------------------------------------------------------------------------------------

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










