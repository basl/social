//
//  PreferencesController.m
//
//  Created by David Donszik on 23.09.11.
//  Copyright (c) David Donszik. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController(Private)
+(NSString*)getDefaultPrefForName:(NSString *)name;
@end

@implementation PreferencesController

#pragma mark - Public Methods

+(int)getIntPrefForName:(NSString *)name
{
    Boolean isCorrect = false;
    NSInteger ret = CFPreferencesGetAppIntegerValue((__bridge CFStringRef)(name), kCFPreferencesCurrentApplication, &isCorrect);
    return ret;
}

+(void)setIntPref:(int)value forKey:(NSString *)key
{
    CFNumberRef n = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &value);
    CFPreferencesSetAppValue((__bridge CFStringRef)(key), n, kCFPreferencesCurrentApplication);
    CFRelease(n);
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

+(BOOL)getBoolPrefForName:(NSString *)name
{
    BOOL ret = NO;
    CFBooleanRef b = CFPreferencesCopyAppValue((__bridge CFStringRef)(name), kCFPreferencesCurrentApplication);
    if (b)
    {
        ret = CFBooleanGetValue(b) ? YES : NO;
        CFRelease(b);
    }
    else
    {
        ret = [[PreferencesController getDefaultPrefForName:name] boolValue];
    }
    return ret;
}

+(void)setBoolPref:(BOOL)value forKey:(NSString *)key
{
    if (value)
    {
        CFPreferencesSetAppValue((__bridge CFStringRef)(key), kCFBooleanTrue, kCFPreferencesCurrentApplication);
    }
    else
    {
        CFPreferencesSetAppValue((__bridge CFStringRef)(key), kCFBooleanFalse, kCFPreferencesCurrentApplication);
    }
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

+(NSString*)getStringPrefForName:(NSString *)name
{
    NSString *ret = NULL;
    CFPropertyListRef val = (CFPreferencesCopyAppValue((__bridge CFStringRef)(name), kCFPreferencesCurrentApplication));
    if (val)
    {
        ret = (__bridge NSString *)val;
        CFRelease(val);
    }
    else
    {
        ret = [PreferencesController getDefaultPrefForName:name];
    }
    return ret;
}

+(void)setStringPref:(NSString *)value forKey:(NSString *)key
{
    CFStringRef s = (__bridge CFStringRef)(value);
    CFPreferencesSetAppValue((__bridge CFStringRef)(key), s, kCFPreferencesCurrentApplication);
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
}

#pragma mark - Private Methods

+(NSString*)getDefaultPrefForName:(NSString *)name {
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
        if ([keyValueStr isEqualToString:name])
        {
            return (NSString*)defaultValue;
        }       
    }
    return NULL;
}

@end
