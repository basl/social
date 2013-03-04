//
//  ILCommentEventCell.h
//  socialiPhoneApp
//
//  Created by David Donszik on 19.02.13.
//  Copyright (c) 2013 David Donszik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILCommentEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attributedTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

- (float)calculatedHeight;
- (void)createShadow;

+ (float)expectedHeightWithText:(NSString *)text;
@end