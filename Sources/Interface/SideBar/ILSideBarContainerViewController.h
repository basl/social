//
//  ILSideBarContainerViewController.h
//  Social
//
//  Created by Bastian Lengert on 26.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSideBarTableViewController.h"

@interface ILSideBarContainerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *sideBarView;
@property (nonatomic, strong) ILSideBarTableViewController *sideBarViewController;
@end
