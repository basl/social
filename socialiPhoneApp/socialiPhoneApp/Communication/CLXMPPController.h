//
//  CLXMPPController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 21.01.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLEventModule;
@class CLRosterController;
@class PLEvent;

@interface CLXMPPController : NSObject

@property (nonatomic, strong) NSString *jabberID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong, readonly) CLRosterController *rosterController;
@property (nonatomic, strong, readonly) PLEventModule *eventModule;

/**
 * Singleton Method
 */
+ (CLXMPPController *)sharedInstance;

/**
 * This method tries to connect to the XMPPStream if needed.
 * jabberID and password must be set, or no connection can be established.
 * @return TRUE, if the stream was or gets connected, FALSE otherwise.
 */
- (BOOL)connect;

- (void)sendEvent:(PLEvent *)event toUser:(NSArray *)jids;

- (void)sendEventToUser:(NSString *)jid; //TODO: remove - testing

@end
