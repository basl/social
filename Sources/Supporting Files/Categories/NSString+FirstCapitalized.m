//
//  NSString+FirstCapitalized.m
//  socialiPhoneApp
//
//  Created by David Donszik on 22.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "NSString+FirstCapitalized.h"

@implementation NSString (FirstCapitalized)

- (NSString *)firstCapRestLow
{
    if ([self length] == 0) {
        return nil;
    }
    if ([self length] == 1) {
        return [self capitalizedString];
    }
    else
    {
        NSString *firstChar = [[self substringToIndex:1] capitalizedString];
        
        /* remove any diacritic mark */
        NSString *lowerRest = [[self substringFromIndex:1] lowercaseString];
        
        return [firstChar stringByAppendingString:lowerRest];
    }
}

@end
