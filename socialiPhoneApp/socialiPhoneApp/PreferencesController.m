//
//  PreferencesController.m
//
//  Created by David Donszik on 23.09.11.
//  Copyright (c) David Donszik. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController(Private)
+(NSString*)getDefaultPrefForName:(CFStringRef)name;
@end

@implementation PreferencesController

#pragma mark - Public Methods

/**
 * Returns the saved integer for the name or 0, if none is defined jet.
 */
+(int)getIntPrefForName:(CFStringRef)name
{
    Boolean isCorrect = false;
    NSInteger ret = CFPreferencesGetAppIntegerValue(name, kCFPreferencesCurrentApplication, &isCorrect);
    return ret;
}

+(void)setIntPref:(int)value forKey:(CFStringRef)key
{
    CFNumberRef n = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
    CFPreferencesSetAppValue(key, n, kCFPreferencesCurrentApplication);
    CFRelease(n);
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

+(NSString*)getBoolPrefForName:(CFStringRef)name
{
    NSString* ret = NULL;
    CFBooleanRef b = CFPreferencesCopyAppValue(name, kCFPreferencesCurrentApplication);
    if (b) {
        ret = CFBooleanGetValue(b) ? @"YES" : @"NO";
    }
    if (b) {
        CFRelease(b);
        return ret;
    }
    return [PreferencesController getDefaultPrefForName:name];
}

+(void)setBoolPref:(BOOL)value forKey:(CFStringRef)key
{
    if (value) {
        CFPreferencesSetAppValue(key, kCFBooleanTrue, kCFPreferencesCurrentApplication);
    } else {
        CFPreferencesSetAppValue(key, kCFBooleanFalse, kCFPreferencesCurrentApplication);
    }
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

#pragma mark - Private Methods

+(NSString*)getDefaultPrefForName:(CFStringRef)name {
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
    NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
    
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    NSDictionary *prefItem;
    for (prefItem in prefSpecifierArray)
    {
        NSString *keyValueStr = [prefItem objectForKey:@"Key"];
        id defaultValue = [prefItem objectForKey:@"DefaultValue"];
        if ([keyValueStr isEqualToString:(__bridge NSString*)name])
        {
            return (NSString*)defaultValue;
        }       
    }
    return NULL;
}

@end
