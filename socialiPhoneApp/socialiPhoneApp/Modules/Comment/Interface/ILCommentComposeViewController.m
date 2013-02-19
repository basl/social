//
//  ILCommentComposeViewController.m
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "ILCommentComposeViewController.h"
#import "XMPPMessage+MLEvent.h"
#import "PLEvent.h"
#import "CLXMPPController.h"
#import "MLEventCoreDataStorageObject.h"
#import "MLUserCoreDataStorageObject.h"
#import "ILCommentBodyCell.h"
#import "ILRecipientsViewController.h"
#import "SOLogging.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ILCommentComposeViewController ()
@property (strong, nonatomic) NSMutableArray *recipients; // of XMPPJID
@end

@implementation ILCommentComposeViewController

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

    self.recipients = [NSMutableArray array];
    if (self.parent) {
        // get all recipients for this event
        // Add sender of the event
        [self.recipients addObject:[XMPPJID jidWithString:self.parent.from.jid]];
        for (MLUserCoreDataStorageObject *user in self.parent.receiver) {
            
            //Add all destinct recipients
            BOOL addRecipient = YES;
            for (XMPPJID *jid in self.recipients) {
                if ([[jid bare] isEqualToString:user.jid]) {
                    addRecipient = NO;
                }
            }
            
            if (addRecipient)
            {
                [self.recipients addObject:[XMPPJID jidWithString:user.jid]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Storyboard

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowRecipients"])
    {
        ILRecipientsViewController *controller = segue.destinationViewController;
        controller.recipients = self.recipients;
    }
}

#pragma mark - Table view data source

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)clickDone:(UIBarButtonItem *)sender {
    //TODO: move this to PLCommentModule (when it's created...)
    // send comment
    if (!self.recipients || [self.recipients count] < 1) {
        DDLogWarn(@"Can't send Comment without recipients");
        return;
    }
    
    NSString *parentId;
    if (self.parent)
    {
        parentId = self.parent.eventId;
    }
    
    // attribute "from" should be added later
    PLEvent *event = [PLEvent eventWithParent:parentId
                                          from:nil
                                            to:self.recipients];
    
    
    //TODO: create subclass of PLEvent for Comment
    NSXMLElement *body = [[NSXMLElement alloc] initWithName:@"body"];
    [body setStringValue:self.bodyText.text];
    
    NSXMLElement *comment = [[NSXMLElement alloc] initWithName:@"comment"];
    [comment addChild:body];
    [event setData:comment];
    
    [[CLXMPPController sharedInstance] sendEvent:event toUser:self.recipients];
    
    if (self.delegate) {
        [self.delegate done];
    }
}

- (IBAction)clickCancel:(UIBarButtonItem *)sender {
    DDLogVerbose(@"Cancel composing comment.");
    if (self.delegate) {
        [self.delegate done];
    }
}
@end





