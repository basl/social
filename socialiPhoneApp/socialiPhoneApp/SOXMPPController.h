//
//  SOXMPPController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 21.01.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOXMPPController : NSObject

@property (nonatomic, strong) NSString *jabberID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;

/**
 * Singleton Method
 */
+ (SOXMPPController *)sharedInstance;

/**
 * This method tries to connect to the XMPPStream if needed.
 * jabberID and password must be set, or no connection can be established.
 * @return TRUE, if the stream was or gets connected, FALSE otherwise.
 */
- (BOOL)connect;

@end
