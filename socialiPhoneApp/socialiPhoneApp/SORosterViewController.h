//
//  SORosterViewController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 27.01.13.
//  Copyright (c) 2013 greenbytes GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SORosterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
