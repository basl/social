//
//  PreferencesController.h
//
//  Created by David Donszik on 23.09.11.
//  Copyright (c) 2011 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesController : NSObject


+(int)getIntPrefForName:(NSString *)name;
+(void)setIntPref:(int)value forKey:(NSString *)key;

+(BOOL)getBoolPrefForName:(NSString *)name;
+(void)setBoolPref:(BOOL)value forKey:(NSString *)key;

+(NSString*)getStringPrefForName:(NSString *)name;
+(void)setStringPref:(NSString *)value forKey:(NSString *)key;

@end
