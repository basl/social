//
//  XMPPMessage+MLEvent.h
//  socialiPhoneApp
//
//  Created by David Donszik on 06.02.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import "XMPPMessage.h"

@interface XMPPMessage (MLEvent)

- (BOOL)hasValidEvents;
- (NSArray *)getValidEvents;

@end
