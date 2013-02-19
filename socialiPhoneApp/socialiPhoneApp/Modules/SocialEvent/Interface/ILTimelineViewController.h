//
//  ILTimelineViewController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ILCommentComposeViewController.h"

@class MLEventCoreDataStorageObject;

@interface ILTimelineViewController : UITableViewController <NSFetchedResultsControllerDelegate, ILCommentComposeDelegate>
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) MLEventCoreDataStorageObject *parent;
@end
