//
//  LoudTableCell.h
//  WhoHelp
//
//  Created by cloud on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface LoudTableCell : UITableViewCell
{
@private
    UIImageView *avatarImage, *arrowImage;
    UILabel *nameLabel, *timeLabel, *distanceLabel;
    OHAttributedLabel *cellText;
    UIButton *bgButton;
}

@property (nonatomic, retain) UIImageView *avatarImage, *arrowImage;
@property (nonatomic, retain) UILabel *nameLabel, *timeLabel, *distanceLabel;
@property (nonatomic, retain) OHAttributedLabel *cellText;
@property (nonatomic, retain) UIButton *bgButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
