//
//  PLEvent.m
//  socialiPhoneApp
//
//  Created by David Donszik on 18.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLEvent.h"
#import <objc/runtime.h>

static NSString * const RECIPIENTS = @"recipients";
static NSString * const RECIPIENT = @"recipient";

@implementation PLEvent

//---------------------------------------------------------------------------------------
#pragma mark - VALIDATION
//---------------------------------------------------------------------------------------

+ (BOOL)isValidEvent:(NSXMLElement *)element
{
    PLEvent *event = [PLEvent eventFromElement:element];

    if (!event) return NO;
    
    if (![event from]) return NO;
    
    if (!event.eventId || [event.eventId isEqualToString:@""]) return NO;
    
    NSArray *recipients = event.recipients;
    if (!recipients || [recipients count] == 0) return NO;
    
    return YES;
}

//---------------------------------------------------------------------------------------
#pragma mark - Creation
//---------------------------------------------------------------------------------------

+ (PLEvent *)eventFromElement:(NSXMLElement *)element
{
	object_setClass(element, [PLEvent class]);
	
	return (PLEvent *)element;
}

+ (PLEvent *)event
{
    return [[PLEvent alloc] init];
}


+ (PLEvent *)eventWithParent:(NSString *)parentId
{
    PLEvent *event = [[PLEvent alloc] init];
    
    if (parentId != nil)
    {
        [event setParentId:parentId];
    }
    return event;
}

+ (PLEvent *)eventWithParent:(NSString *)parentId from:(XMPPJID *)fromJID
{
    PLEvent *event = [PLEvent eventWithParent:parentId];
    
    if (event) {
        [event setFrom:fromJID];
    }
    return event;
}

+ (PLEvent *)eventWithParent:(NSString *)parentId from:(XMPPJID *)fromJID to:(NSArray *)recipients
{
    PLEvent *event = [PLEvent eventWithParent:parentId from:fromJID];
    
    if (event) {
        [event setRecipients:recipients];
    }
    return event;
}

- (id)init
{
    self = [super initWithName:@"event"];
    if (self)
    {
        [self setXmlns:@"urn:social:event"];
        [self setEventId:[[NSUUID UUID] UUIDString]];
    }
    return self;
}

//---------------------------------------------------------------------------------------
#pragma mark - Encoding, Decoding
//---------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)coder
{
	NSString *xmlString;
	if([coder allowsKeyedCoding])
	{
		xmlString = [coder decodeObjectForKey:@"xmlString"];
	}
	else
	{
		xmlString = [coder decodeObject];
	}
	
	// The method [super initWithXMLString:error:] may return a different self.
	// In other words, it may [self release], and alloc/init/return a new self.
	//
	// So to maintain the proper class we need to get a reference to the class
    // before invoking super.
	
	Class selfClass = [self class];
	
	if ((self = [super initWithXMLString:xmlString error:nil]))
	{
		object_setClass(self, selfClass);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	NSString *xmlString = [self compactXMLString];
	
	if([coder allowsKeyedCoding])
	{
		[coder encodeObject:xmlString forKey:@"xmlString"];
	}
	else
	{
		[coder encodeObject:xmlString];
	}
}

//---------------------------------------------------------------------------------------
#pragma mark - Copying
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
	NSXMLElement *elementCopy = [super copyWithZone:zone];
	object_setClass(elementCopy, [self class]);
	
	return elementCopy;
}

//---------------------------------------------------------------------------------------
#pragma mark - Setter
//---------------------------------------------------------------------------------------

- (void)setEventId:(NSString *)eventId
{
    [self addAttributeWithName:@"eventid" stringValue:eventId];
}

- (void)setParentId:(NSString *)parentId
{
    [self addAttributeWithName:@"parentid" stringValue:parentId];
}

- (void)setFrom:(XMPPJID *)fromJID
{
    [self addAttributeWithName:@"from" stringValue:[fromJID bare]];
}

- (void)setRecipients:(NSArray *)recipients
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:RECIPIENTS];
    
    for (XMPPJID *recipient in recipients)
    {
        NSXMLElement *child = [[NSXMLElement alloc] initWithName:RECIPIENT];
        [child addAttributeWithName:@"jid" stringValue:[recipient bare]];
        [element addChild:child];
    }
    [self addChild:element];
}

- (void)setData:(NSXMLElement *)data
{
    [self addChild:data];
}

//---------------------------------------------------------------------------------------
#pragma mark - Getter
//---------------------------------------------------------------------------------------

- (NSString *)type
{
    return [[self getData] name];
}

- (NSString *)eventId
{
    return [[self attributeForName:@"eventid"] stringValue];
}

- (NSString *)parentId
{
    return [[self attributeForName:@"parentid"] stringValue];
}

- (XMPPJID *)from
{
    return [XMPPJID jidWithString:[self fromStr]];
}

- (NSString *)fromStr
{
    return [[self attributeForName:@"from"] stringValue];
}

- (NSArray *)recipients
{
    NSXMLElement *node = [self elementForName:RECIPIENTS];
    
    if (!node) return nil;
    
    NSArray *elements = [node elementsForName:RECIPIENT];
    NSMutableArray *recipients = [NSMutableArray arrayWithCapacity:[elements count]];
    
    for (NSXMLElement *element in elements)
    {
        NSString *recipientJID = [[element attributeForName:@"jid"] stringValue];
        XMPPJID *jid = [XMPPJID jidWithString:recipientJID];
        if (jid) {
            [recipients addObject:jid];
        }
    }
    
    return recipients;
}

- (NSXMLElement *)getData
{
    for (NSXMLElement *child in [self children]) {
        if (![[child name] isEqualToString:RECIPIENTS]) {
            return child;
        }
    }
    return nil;
}

@end
