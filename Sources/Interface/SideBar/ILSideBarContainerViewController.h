//
//  ILSideBarContainerViewController.h
//  Social
//
//  Created by Bastian Lengert on 26.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSideBarTableViewController.h"
#import "ILMainViewControllerDelegate.h"
#import "ILSideBarTableViewControllerDelegate.h"

@interface ILSideBarContainerViewController : UIViewController<ILMainViewControllerDelegate, ILSideBarTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainViewContainer;
@property (weak, nonatomic) IBOutlet UIView *sideBarView;
@property (nonatomic, strong) ILSideBarTableViewController *sideBarViewController;
@end
