//
//  PLEvent.h
//  socialiPhoneApp
//
//  Created by David Donszik on 18.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSXMLElement+XMPP.h"
#import "XMPPJID.h"
/**
 * PLEvent provides the base class of all events provided by modules.
 *
 * This class extends NSXMLElement.
 * The NSXML classes (NSXMLElement & NSXMLNode) provide a full-featured library for working with XML elements.
 *
 * On the iPhone, the KissXML library provides a drop-in replacement for Apple's NSXML classes.
 **/

@interface PLEvent : NSXMLElement <NSCoding, NSCopying>

//---------------------------------------------------------------------------------------
#pragma mark - VALIDATION
//---------------------------------------------------------------------------------------

/**
 * @param element The event in question.
 * @return True, if the given element conforms to the protocol (https://github.com/basl/social/wiki/Protocol)
 */
+ (BOOL)isValidEvent:(NSXMLElement *)element;

//---------------------------------------------------------------------------------------
#pragma mark - Creation
//---------------------------------------------------------------------------------------

/**
 * Will convert the NSXMLElement into PLEvent without allocating memory.
 * @param element is the NSXMLElement from which information is extracted to create a PLEvent
 * @return The event for the XMLElement.
 */
+ (PLEvent *)eventFromElement:(NSXMLElement *)element;

/**
 * Will allocate and initialize a basic event with xmlns and eventid set.
 */
+ (PLEvent *)event;

/**
 * Will allocate and initialize a basic event with xmlns and eventid set.
 * @param parentId the UUID of the parent event as a string.
 */
+ (PLEvent *)eventWithParent:(NSString *)parentId;

/**
 * Will allocate and initialize a basic event with xmlns and eventid set.
 * @param parentId the UUID of the parent event as a string.
 * @param fromJID the JID of the creator of this event.
 */
+ (PLEvent *)eventWithParent:(NSString *)parentId from:(XMPPJID *)fromJID;

/**
 * Will allocate and initialize a basic event with xmlns and eventid set.
 * @param parentId the UUID of the parent event as a string.
 * @param fromJID the JID of the creator of this event.
 * @param recipients the XMPPJIDs of the recipients
 */
+ (PLEvent *)eventWithParent:(NSString *)parentId from:(XMPPJID *)fromJID to:(NSArray *)recipients;

//---------------------------------------------------------------------------------------
#pragma mark - Setter
//---------------------------------------------------------------------------------------

/**
 * @param eventId the UUID of the event as a string.
 */
- (void)setEventId:(NSString *)eventId;

/**
 * @param parentId the UUID of the parent event as a string.
 */
- (void)setParentId:(NSString *)parentId;

/**
 * @param fromJID the JID of the creator of this event.
 */
- (void)setFrom:(XMPPJID *)fromJID;

/**
 * @param recipients the XMPPJIDs of the recipients
 */
- (void)setRecipients:(NSArray *)recipients;

/**
 * @param data must include a specific type of event but not the PLEvent itself
 */
- (void)setData:(NSXMLElement *)data;

//---------------------------------------------------------------------------------------
#pragma mark - Getter
//---------------------------------------------------------------------------------------

/**
 * @return The module type as string.
 */
- (NSString *)type;

/**
 * @return UUID of the event.
 */
- (NSString *)eventId;

/**
 * @return UUID of the parent event. May be nil.
 */
- (NSString *)parentId;

/**
 * @return XMPPJID of the creator of this event.
 */
- (XMPPJID *)from;

/**
 * @return JID-string of the creator of this event.
 */
- (NSString *)fromStr;

/** 
 * @return NSArray of XMPPJID
 */
- (NSArray *)recipients;

/**
 * @return The first child 
 */
- (NSXMLElement *)getData;

@end
