//
//  ILCommentEventCell.m
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import "ILCommentEventCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation ILCommentEventCell

#pragma mark - Public Methods

- (void)createShadow
{
    self.attributedTextLabel.superview.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.attributedTextLabel.superview.layer.shadowOpacity = 0.6f;
    self.attributedTextLabel.superview.layer.shadowRadius = 4.f;
    self.attributedTextLabel.superview.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.attributedTextLabel.superview.bounds] CGPath];
    self.attributedTextLabel.superview.layer.shadowOffset = CGSizeMake(0.f, 1.f);
}

- (float)calculatedHeight
{
    float calculatedHeight = 0.f;
    
    CGSize size = [self.attributedTextLabel.text sizeWithFont:self.attributedTextLabel.font
                                                     forWidth:self.attributedTextLabel.bounds.size.width
                                                lineBreakMode:self.attributedTextLabel.lineBreakMode];
    
    calculatedHeight = size.height;
    
    return calculatedHeight;
}

+ (float)expectedHeightWithText:(NSString *)text
{
    float calculatedHeight = 0.f;
    
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.f]
                            constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 77.f, 100000.f)];
    
    calculatedHeight = size.height;
    calculatedHeight += 22.f;
    
    return MAX(calculatedHeight, 60.f);
}

@end
