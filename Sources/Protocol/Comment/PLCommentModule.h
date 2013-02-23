//
//  PLCommentModule.h
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLModule.h"

@interface PLCommentModule : PLModule
/**
 * Will send the comment to the recipients.
 * @param body The actual message of the comment.
 * @param parentId The UUID of a parent Event. May be null if there is none
 * @param recipients Array of XMPPJIDs of the recipients.
 */
+ (void)sendComment:(NSString *)body
          forParent:(NSString *)parentId
                 to:(NSArray *)recipients;

@end
