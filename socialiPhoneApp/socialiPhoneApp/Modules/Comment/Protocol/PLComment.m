//
//  PLComment.m
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLComment.h"
#import <objc/runtime.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@implementation PLComment

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Verification
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (BOOL)isComment:(PLEvent *)event
{
    BOOL isValid = YES;
    NSXMLElement *comment = [event elementForName:@"comment"];
    
    if (!comment) {
        isValid = NO;
    }
    
    NSXMLElement *body = [comment elementForName:@"body"];
    
    if (!body) {
        isValid = NO;
    }
    
    return isValid;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (PLComment *)commentFromEvent:(PLEvent *)event
{
    object_setClass(event, [PLComment class]);
    
	return (PLComment *)event;
}

+ (PLComment *)commentWithEvent:(PLEvent *)event body:(NSString *)body
{
    PLComment *comment = [PLComment commentFromEvent:event];
	
    [comment setBody:body];
    
	return comment;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setter/Getter
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setBody:(NSString *)theBody
{
    NSXMLElement *body = [[NSXMLElement alloc] initWithName:@"body"];
    [body setStringValue:theBody];
    
    NSXMLElement *comment = [[NSXMLElement alloc] initWithName:@"comment"];
    [comment addChild:body];
    [self setData:comment];
}

- (NSString *)body
{
    NSXMLElement *comment = [self elementForName:@"comment"];
    
    if (!comment) {
        DDLogWarn(@"This event has no comment element!");
        return nil;
    }
    
    NSXMLElement *body = [comment elementForName:@"body"];
    
    if (!body) {
        DDLogWarn(@"This event has no body element!");
        return nil;
    }
    
    return [body stringValue];
}

@end
