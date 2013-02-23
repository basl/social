//
//  PreferencesController.h
//
//  Created by David Donszik on 23.09.11.
//  Copyright (c) 2011 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * If there is no stored value, the PreferencesController tries to find default values.
 */
@interface PreferencesController : NSObject

/**
 * This won't return a default value from the prefs. Should get fixed.
 * @param name The name of the preference.
 * @return The saved integer for the name or 0, if none is defined jet.
 */
+(int)getIntPrefForName:(NSString *)name;

/**
 * Sets the integer in the user defaults.
 * @param value The integer value.
 * @param key The key.
 */
+(void)setIntPref:(int)value forKey:(NSString *)key;

/**
 * @param name The name of the preference.
 * @return The saved boolean value or false.
 */
+(BOOL)getBoolPrefForName:(NSString *)name;

/**
 * Sets the boolean in the user defaults.
 * @param value The boolean value.
 * @param key The key.
 */
+(void)setBoolPref:(BOOL)value forKey:(NSString *)key;

/**
 * @param name The name of the preference.
 * @return The saved string value or nil.
 */
+(NSString*)getStringPrefForName:(NSString *)name;

/**
 * Sets the string in the user defaults.
 * @param value The string value.
 * @param key The key.
 */
+(void)setStringPref:(NSString *)value forKey:(NSString *)key;

@end
