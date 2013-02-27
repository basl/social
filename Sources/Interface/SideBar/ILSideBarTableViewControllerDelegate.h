//
//  ILSideBarTableViewControllerDelegate.h
//  Social
//
//  Created by Bastian Lengert on 27.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ILSideBarTableViewControllerDelegate <NSObject>
- (void)selectedSideBarElementWithViewControllerName:(NSString *)viewControllerName;
@end
