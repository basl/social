//
//  XMPPMessage+MLEvent.m
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "XMPPMessage+MLEvent.h"

@implementation XMPPMessage (MLEvent)

- (BOOL)hasValidEvents
{
    BOOL hasEvents = NO;
    NSArray *events = [self elementsForLocalName:@"event" URI:@"urn:social:event"];
    if (events != nil)
    {
        for (NSXMLElement *event in events) {
            if ([self isValidEvent:event])
            {
                hasEvents = YES;
                break;
            }
        }
    }
    return hasEvents;
}

- (NSArray *)getValidEvents
{
    NSArray *events = [self elementsForLocalName:@"event" URI:@"urn:social:event"];
    
    if (events == nil)
    {
        return nil;
    }
    
    NSMutableArray *validEvents = [[NSMutableArray alloc] initWithCapacity:[events count]];
    
    for (NSXMLElement *event in events) {
        if ([self isValidEvent:event])
        {
            [validEvents addObject:event];
        }
    }
    
    return validEvents;
}

- (BOOL)isValidEvent:(NSXMLElement *)event
{
    return [event attributeForName:@"eventId"] != nil;
}

@end
