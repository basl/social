//
//  PLComment.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLEvent.h"

/**
 * A comment ist the most common event. 
 *
 * It can be used to post directly on the timeline (then no parent element is included).
 * Or it may be used to comment another event. 
 * https://github.com/basl/social/wiki/Protocol
 */
@interface PLComment : PLEvent {}

//---------------------------------------------------------------------------------------
#pragma mark - Verification
//---------------------------------------------------------------------------------------

/**
 * Will not check if the event is really a valid event [PLEvent isValidEvent:]
 *
 * @param event The event in question.
 * @return true, if the event is a valid comment
 */
+ (BOOL)isComment:(PLEvent *)event;

//---------------------------------------------------------------------------------------
#pragma mark - Creation
//---------------------------------------------------------------------------------------

/**
 * Will convert the PLEvent into PLComment without allocating memory.
 * @param event The event in question.
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
