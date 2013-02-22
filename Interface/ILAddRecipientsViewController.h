//
//  ILAddRecipientsViewController.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol ILAddRecipientDelegate <NSObject>
- (void)addRecipients:(NSArray *)recipients;
@end

@interface ILAddRecipientsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id<ILAddRecipientDelegate> delegate;

- (IBAction)clickDone:(UIBarButtonItem *)sender;
@end
