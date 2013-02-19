//
//  ILRecipientsViewController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ILAddRecipientsViewController.h"

@interface ILRecipientsViewController : UITableViewController <NSFetchedResultsControllerDelegate, ILAddRecipientDelegate>

@property (strong, nonatomic) NSMutableArray *recipients; // of MLUserCoreDataStorageObject

@end
