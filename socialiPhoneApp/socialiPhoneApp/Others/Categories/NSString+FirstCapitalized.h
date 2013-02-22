//
//  NSString+FirstCapitalized.h
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FirstCapitalized)
/**
 * @return A new string with the contents of the prior one - but with a capital first letter 
 * and following lowercase.
 */
- (NSString *)firstCapRestLow;

@end
