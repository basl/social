//
//  PLCommentModule.m
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLCommentModule.h"
#import "CLModuleController.h"
#import "PLEvent.h"
#import "PLComment.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation PLCommentModule

+ (void)sendComment:(NSString *)body
          forParent:(NSString *)parentId
                 to:(NSArray *)recipients
{
    if (!body) {
        DDLogWarn(@"Trying to send Comment with empty body.");
        return;
    }
    
    PLEvent *event = [PLEvent eventWithParent:parentId
                                         from:nil // remove? will be added later 
                                           to:recipients];
    
    PLComment *comment = [PLComment commentWithEvent:event body:body];
    
    [[CLModuleController sharedInstance] sendEvent:comment toUser:recipients];
}
@end
