//
//  PreferencesController.h
//  Scherzanruf
//
//  Created by David Donszik on 23.09.11.
//  Copyright (c) 2011 4logic GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesController : NSObject


+(int)getIntPrefForName:(CFStringRef)name;
+(void)setIntPref:(int)value forKey:(CFStringRef)key;

+(NSString*)getBoolPrefForName:(CFStringRef)name;
+(void)setBoolPref:(BOOL)value forKey:(CFStringRef)key;

@end
