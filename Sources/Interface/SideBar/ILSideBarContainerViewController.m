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

#define kILSideBarContainerMinVelocity 200.f

@interface ILSideBarContainerViewController ()
@property (nonatomic) float initialSideBarPos;
@property (nonatomic) BOOL isSideBarOut;
@end

@implementation ILSideBarContainerViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // resetting the shadow for intial setup
    self.mainView.layer.shadowPath = [[UIBezierPath
                                  bezierPathWithRect:self.mainView.bounds] CGPath];
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
            UIView *addedView = [((UIViewController *)segue.destinationViewController) view];
            [self configureAddedMainViewSubview:addedView];
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

- (void)setMainView:(UIView *)mainView
{
    if (_mainView != mainView) {
        _mainView = mainView;
        
        
        mainView.layer.cornerRadius = 3.f;
        mainView.layer.shadowColor = [[UIColor blackColor] CGColor];
        mainView.layer.shadowOpacity = 0.4f;
        mainView.layer.shadowOffset = CGSizeMake(-4.f, 0.f);
        mainView.layer.shadowPath = [[UIBezierPath
                                      bezierPathWithRect:mainView.bounds] CGPath];
    }
}

#pragma mark - Animations

- (void)slideSideBarOut
{
    float progress = (self.sideBarView.frame.size.width - self.mainView.frame.origin.x) / self.sideBarView.frame.size.width;
    float duration = kILAnimationUtilDefaultAnimationDuration * progress;
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.mainView.center = CGPointMake(self.sideBarView.frame.size.width + self.mainView.frame.size.width / 2.f,
                                           self.mainView.center.y);
        self.sideBarView.center = CGPointMake(self.sideBarView.frame.size.width / 2.f,
                                           self.sideBarView.center.y);
    }];
    self.isSideBarOut = YES;
}

- (void)slideSideBarIn
{
    float progress = self.mainView.frame.origin.x / self.sideBarView.frame.size.width;
    float duration = kILAnimationUtilDefaultAnimationDuration * progress;
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.mainView.center = CGPointMake(self.mainView.frame.size.width / 2.f,
                                           self.mainView.center.y);
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
        
        float mainCenterX = sideBarCenterX + self.sideBarView.frame.size.width / 2.f + self.mainView.frame.size.width / 2.f;
        self.mainView.center = CGPointMake(mainCenterX ,
                                           self.mainView.center.y);
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

@end
