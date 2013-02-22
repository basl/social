//
//  PLCommentModule.h
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "PLModule.h"

@interface PLCommentModule : PLModule

+ (void)sendComment:(NSString *)body
          forParent:(NSString *)parentId
                 to:(NSArray *)recipients;

@end
