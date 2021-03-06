//
//  ILSideBarTableViewController.h
//  Social
//
//  Created by Bastian Lengert on 26.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSideBarTableViewControllerDelegate.h"

@interface ILSideBarTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIView *tableViewFooter;
@property (nonatomic, weak) id<ILSideBarTableViewControllerDelegate>delegate;
@end
