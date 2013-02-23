//
//  PLComment.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLEvent.h"

@interface PLComment : PLEvent

//---------------------------------------------------------------------------------------
#pragma mark - Verification
//---------------------------------------------------------------------------------------

/**
 * @return true, if the event is a valid comment
 */
+ (BOOL)isComment:(PLEvent *)event;

//---------------------------------------------------------------------------------------
#pragma mark - Creation
//---------------------------------------------------------------------------------------

/**
 * Will convert the PLEvent into PLComment without allocating memory.
 * @return The comment for the PLEvent.
 */
+ (PLComment *)commentFromEvent:(PLEvent *)event;

/**
 * Will convert the PLEvent into PLComment and add elements to it.
 * @param event The base event, which should include the comment.
 * @param body The comment message.
 * @return The comment based on the given event with a body.
 */
+ (PLComment *)commentWithEvent:(PLEvent *)event body:(NSString *)body;


//---------------------------------------------------------------------------------------
#pragma mark - Getter
//---------------------------------------------------------------------------------------

/**
 * @return The body of the comment.
 */
- (NSString *)body;

@end
