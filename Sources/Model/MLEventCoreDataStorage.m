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
    
    for (NSXMLElement *eventXML in [message getValidEvents]) {
        
        PLEvent *event = [PLEvent eventFromElement:eventXML];
        
        NSString *eventId = event.eventId;
        
        // Parent ID is optional, but if its present, then the parent MUST be persisted
        MLEventCoreDataStorageObject *parent;
        NSString *parentId = event.parentId;
        if (parentId != nil) {
            parent = [MLEventCoreDataStorage fetchEventForID:parentId managedObjectContext:moc];
            if (parent == nil)
            {
                DDLogError(@"Structural Error: Parent of event not persisted. Discarding Event.");
                break;
            }
        }
        
        MLUserCoreDataStorageObject *fromUser = [MLEventCoreDataStorage fetchOrCreateUserForJID:event.from managedObjectContext:moc];
        if (fromUser == nil)
        {
            DDLogError(@"Structural Error: Could not load or create user. Discarding Event.");
            break;
        }
        
        MLUserCoreDataStorageObject *toUser;
        NSMutableSet *recipients = [NSMutableSet set];
        for (XMPPJID *recipient in event.recipients) {
            toUser = [MLEventCoreDataStorage fetchOrCreateUserForJIDStr:[recipient bare] managedObjectContext:moc];
            if (toUser == nil)
            {
                DDLogError(@"Structural Error: Could not load or create user. Discarding Event.");
                break;
            }
            [recipients addObject:toUser];
        }
        
        MLModuleDataCoreDataStorageObject *moduleData = [self createModuleDataForEvent:event
                                                                  managedObjectContext:moc];
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
        newEvent.moduleData = moduleData;
    }
}


//---------------------------------------------------------------------------------------
#pragma mark - PRIVATE METHODS
//---------------------------------------------------------------------------------------

+ (MLModuleDataCoreDataStorageObject *)createModuleDataForEvent:(PLEvent *)event
                                           managedObjectContext:(NSManagedObjectContext *)moc
{
    // Check for the correct Module to create the ModuleDataObject
    NSString * moduleName = event.type;
    if (!moduleName) {
        DDLogWarn(@"Could not determine type of event.");
        return nil;
    }
    // The Factories to create the MLModuleDataCoreDataStorageObject follow these naming conventions:
    // ML*Type*CoreDataStorageObject e.g.: MLCommentCoreDataStorageObject
    // The *Type* MUST have a capital letter and the rest MUST be lowercase.
    
    // Transform *Type* to fit naming conventions
    moduleName = [moduleName firstCapRestLow];
    if (!moduleName)
    {
        DDLogWarn(@"Module type could not be extracted from event.");
        return nil;
    }
    moduleName = [NSString stringWithFormat:@"ML%@CoreDataStorageObject", moduleName];
    
    DDLogVerbose(@"Trying to load moduledata from %@.", moduleName);
    
    Class moduleDataStorage = NSClassFromString(moduleName);
    
    // Try to find the corresponding class for this module
    MLModuleDataCoreDataStorageObject *moduleData;
    if ([moduleDataStorage conformsToProtocol:@protocol(MLModuleDataProtocol)])
    {
        Class<MLModuleDataProtocol> moduleClass = moduleDataStorage;
        moduleData = [moduleClass createModuleDataForEvent:event
                                      managedObjectContext:moc];
    }
    
    return moduleData;
}

+ (MLUserCoreDataStorageObject *)fetchUserForJID:(XMPPJID *)jid
                            managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
	NSString *bareJIDStr = [jid bare];
	return [self fetchUserForJIDstr:bareJIDStr managedObjectContext:moc];
}

+ (MLUserCoreDataStorageObject *)fetchUserForJIDstr:(NSString *)jid
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

+ (MLUserCoreDataStorageObject *)fetchOrCreateUserForJID:(XMPPJID *)jid
                                    managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
	NSString *bareJIDStr = [jid bare];
	return [self fetchOrCreateUserForJIDStr:bareJIDStr managedObjectContext:moc];
}

+ (MLUserCoreDataStorageObject *)fetchOrCreateUserForJIDStr:(NSString *)jid
                                       managedObjectContext:(NSManagedObjectContext *)moc
{
    if (jid == nil) return nil;
    if (moc == nil) return nil;
    
    MLUserCoreDataStorageObject *user = [MLEventCoreDataStorage fetchUserForJIDstr:jid
                                                              managedObjectContext:moc];
    if (user == nil) {
        NSString *userClassName  = NSStringFromClass([MLUserCoreDataStorageObject class]);
        user = [NSEntityDescription insertNewObjectForEntityForName:userClassName
                                             inManagedObjectContext:moc];
        user.jid = jid;
    }
    return user;
}

+ (MLEventCoreDataStorageObject *)fetchEventForID:(NSString *)eventId
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










