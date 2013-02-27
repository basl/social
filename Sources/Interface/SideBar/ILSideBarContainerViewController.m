//
//  ILSideBarContainerViewController.m
//  Social
//
//  Created by Bastian Lengert on 26.02.13.
//  Copyright (c) 2013 Bastian Lengert. All rights reserved.
//

#import "ILSideBarContainerViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "ILAnimationUtil.h"
#import "ILSideBarTableViewController.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#define kILSideBarContainerMinVelocity 200.f

@interface ILSideBarContainerViewController ()
@property (nonatomic) float initialSideBarPos;
@property (nonatomic) BOOL isSideBarOut;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) ILSideBarTableViewController *sideBarController;
@end

@implementation ILSideBarContainerViewController

#pragma mark - Init

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // resetting the shadow for intial setup
    self.mainViewContainer.layer.shadowPath = [[UIBezierPath
                                  bezierPathWithRect:self.mainViewContainer.bounds] CGPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedMainView"]) {
        if ([segue.destinationViewController isKindOfClass:[UIViewController class]]) {
            // keeping reference to viewController
            self.mainViewController = segue.destinationViewController;
            
            // also configuring its view
            UIView *addedView = [((UIViewController *)segue.destinationViewController) view];
            [self configureAddedMainViewSubview:addedView];
        }
    } else if ([segue.identifier isEqualToString:@"ILSideBarEmbed"]) {
        if ([segue.destinationViewController isKindOfClass:[ILSideBarTableViewController class]]) {
            self.sideBarController = segue.destinationViewController;
            self.sideBarController.delegate = self;
        }
    }
}

#pragma mark - View Configuration

- (void)configureAddedMainViewSubview:(UIView *)view
{
    view.layer.cornerRadius = 3.f;
    view.clipsToBounds = YES;
}

#pragma mark - Getter and Setter

- (void)setMainViewContainer:(UIView *)mainViewContainer
{
    if (_mainViewContainer != mainViewContainer) {
        _mainViewContainer = mainViewContainer;
        
        
        mainViewContainer.layer.cornerRadius = 3.f;
        mainViewContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
        mainViewContainer.layer.shadowOpacity = 0.4f;
        mainViewContainer.layer.shadowOffset = CGSizeMake(-4.f, 0.f);
        mainViewContainer.layer.shadowPath = [[UIBezierPath
                                      bezierPathWithRect:mainViewContainer.bounds] CGPath];
    }
}

#pragma mark - Animations

- (void)slideSideBarOut
{
    float progress = (self.sideBarView.frame.size.width - self.mainViewContainer.frame.origin.x) / self.sideBarView.frame.size.width;
    float duration = kILAnimationUtilDefaultAnimationDuration * progress;
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.mainViewContainer.center = CGPointMake(self.sideBarView.frame.size.width + self.mainViewContainer.frame.size.width / 2.f,
                                           self.mainViewContainer.center.y);
        self.sideBarView.center = CGPointMake(self.sideBarView.frame.size.width / 2.f,
                                           self.sideBarView.center.y);
    }];
    self.isSideBarOut = YES;
}

- (void)slideSideBarIn
{
    float progress = self.mainViewContainer.frame.origin.x / self.sideBarView.frame.size.width;
    float duration = kILAnimationUtilDefaultAnimationDuration * progress;
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.mainViewContainer.center = CGPointMake(self.mainViewContainer.frame.size.width / 2.f,
                                           self.mainViewContainer.center.y);
        self.sideBarView.center = CGPointMake(self.sideBarView.frame.size.width / -2.f,
                                              self.sideBarView.center.y);
    }];
    self.isSideBarOut = NO;
}

#pragma mark - Pan Gesture

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.initialSideBarPos = self.sideBarView.center.x;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        float sideBarCenterX = self.initialSideBarPos + translation.x;
        sideBarCenterX = MIN(sideBarCenterX, self.sideBarView.frame.size.width / 2.f);
        sideBarCenterX = MAX(sideBarCenterX, - self.sideBarView.frame.size.width / 2.f);
        
        self.sideBarView.center = CGPointMake(sideBarCenterX,
                                              self.sideBarView.center.y);
        
        float mainCenterX = sideBarCenterX + self.sideBarView.frame.size.width / 2.f + self.mainViewContainer.frame.size.width / 2.f;
        self.mainViewContainer.center = CGPointMake(mainCenterX ,
                                           self.mainViewContainer.center.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (ABS(velocity.x) > kILSideBarContainerMinVelocity) {
            // the velocity is big so we can use it to determine the direction
            if (velocity.x > 0.f) {
                // sideBar is sliding out
                [self slideSideBarOut];
            } else {
                [self slideSideBarIn];
            }
        } else {
            // the velocity is low. Determine direction depending on current sideBar
            // position
            if (self.sideBarView.center.x < 0.f) {
                // sidebar is positioned to the left
                [self slideSideBarIn];
            } else {
                [self slideSideBarOut];
            }
        }
    }
}

#pragma mark - ILMainViewControllerDelegate
//TODO: this might not be needed
- (void)openSideBar
{
    [self slideSideBarOut];
}

#pragma mark - ILSideBarTableViewControllerDelegate

- (void)selectedSideBarElementWithViewControllerName:(NSString *)viewControllerName
{
    if (viewControllerName && ![viewControllerName isEqualToString:@""]) {
        // need name != @""
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerName];
        if (newViewController) {
            // removing old mainView and ViewController
            [self.mainViewController.view removeFromSuperview];
            [self.mainViewController removeFromParentViewController];
            
            // adding new view and viewController
            self.mainViewController = newViewController;
            [self addChildViewController:self.mainViewController];
            [self.mainViewContainer addSubview:newViewController.view];
            [self configureAddedMainViewSubview:self.mainViewController.view];
            
            [self slideSideBarIn];
        } else {
            DDLogError(@"Tried to launch ViewController: %@ but no with this name could be found in storyboard: %@", viewControllerName, self.storyboard);
        }
    } else {
        DDLogError(@"Tried to launch ViewController with empty name!");
    }
}

@end
