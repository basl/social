//
//  ILTimelineViewController.m
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "ILTimelineViewController.h"
#import "ILCommentEventCell.h"
#import "CLModuleController.h"
#import "MLEventCoreDataStorageObject.h"
#import "MLUserCoreDataStorageObject.h"
#import "MLModuleDataCoreDataStorageObject.h"
#import "MLCommentCoreDataStorageObject.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ILTimelineViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MLEventCoreDataStorageObject *composerParent;
@end

@implementation ILTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Storyboard

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventChildren"])
    {
        MLEventCoreDataStorageObject *event = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];

        ILTimelineViewController *controller = segue.destinationViewController;
        controller.parent = event;
    }
    else if ([segue.identifier isEqualToString:@"CreateEvent"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ILCommentComposeViewController *controller = (ILCommentComposeViewController *)navigationController.topViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ComposeComment"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ILCommentComposeViewController *controller = (ILCommentComposeViewController *)navigationController.topViewController;
        controller.parent = self.composerParent;
        controller.delegate = self;
    }
}

#pragma mark NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController == nil)
	{
		//TODO: remove singleton and pass the moc via dependency injection on creation
		NSManagedObjectContext *moc = [[CLModuleController sharedInstance] managedObjectContext];
        if (moc == nil)
        {
            DDLogError(@"Managed Object Context of PLEventModule must not be null.");
            return nil;
        }
        
        NSString *eventClassName  = NSStringFromClass([MLEventCoreDataStorageObject class]);

        NSPredicate *predicate;
        if (self.parent)
        {
            predicate = [NSPredicate predicateWithFormat:@"parent.eventId = %@ OR eventId = %@",self.parent.eventId, self.parent.eventId];
        }
        else
        {
            // Fetch only root events
            predicate = [NSPredicate predicateWithFormat:@"parent = nil"];
        }
        
		NSEntityDescription *entity = [NSEntityDescription entityForName:eventClassName
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"stamp" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:moc
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
		[_fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![_fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
	}
	return _fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

- (MLEventCoreDataStorageObject *)eventAtIndexPath:(NSIndexPath *)indexPath
{
	MLEventCoreDataStorageObject *parentEvent = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.section];
	MLEventCoreDataStorageObject *returnEvent = nil;
	if (indexPath.row == 0) {
		returnEvent = parentEvent;
	} else if (indexPath.row < parentEvent.children.count + 1) {
		//TODO: need to sort children :-(
		returnEvent = [[parentEvent.children allObjects] objectAtIndex:indexPath.row - 1];
	}
	return returnEvent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	MLEventCoreDataStorageObject *event = [[self.fetchedResultsController fetchedObjects] objectAtIndex:sectionIndex];
	
	return event.children.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ILSubCommentCell";
	static NSString *firstCellIdentifier = @"ILCommentCell";
    ILCommentEventCell *cell = nil;
	if (indexPath.row == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:firstCellIdentifier forIndexPath:indexPath];
		cell.backgroundColor = [UIColor blueColor];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
		cell.backgroundColor = [UIColor redColor];
	}
	
    MLEventCoreDataStorageObject *event = [self eventAtIndexPath:indexPath];
    MLModuleDataCoreDataStorageObject *moduleData = event.moduleData;
    
    if ([moduleData isKindOfClass:[MLCommentCoreDataStorageObject class]]) {
        cell.attributedTextLabel.text = ((MLCommentCoreDataStorageObject *)moduleData).body;
    }
    else
    {
        cell.attributedTextLabel.text = event.eventId;
    }
    //cell.detailTextLabel.text = event.from.jid;
    [cell createShadow];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForRow = 0.f;
    
    MLEventCoreDataStorageObject *event = [self eventAtIndexPath:indexPath];
    MLModuleDataCoreDataStorageObject *moduleData = event.moduleData;
    
    if ([moduleData isKindOfClass:[MLCommentCoreDataStorageObject class]]) {
        heightForRow = [ILCommentEventCell expectedHeightWithText:((MLCommentCoreDataStorageObject *)moduleData).body];
    }
    else
    {
        heightForRow = [ILCommentEventCell expectedHeightWithText:event.eventId];
    }
    
    
    
    return heightForRow;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.composerParent = [self eventAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section]];
    [self performSegueWithIdentifier: @"ComposeComment" sender: self];
}

#pragma mark - ILCommentComposeDelegate Methods

- (void)done
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
