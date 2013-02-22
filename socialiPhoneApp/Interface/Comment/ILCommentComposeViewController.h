//
//  ILCommentComposeViewController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ILCommentComposeDelegate <NSObject>
- (void)done;
@end

@class MLEventCoreDataStorageObject;

@interface ILCommentComposeViewController : UITableViewController
@property (weak, nonatomic) id<ILCommentComposeDelegate> delegate;
@property (strong, nonatomic) MLEventCoreDataStorageObject *parent;

@property (weak, nonatomic) IBOutlet UITextView *bodyText;


- (IBAction)clickDone:(UIBarButtonItem *)sender;
- (IBAction)clickCancel:(UIBarButtonItem *)sender;
@end
