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
    UIImageView *avatarImage, *payCateImage, *loudCateImage;
    UILabel *nameLabel, *timeLabel, *cellText, *loudCateLabel;
    UILabel *payCateDescLabel, *commentLabel, *locationDescLabel;
}

@property (nonatomic, retain) UIImageView *avatarImage, *payCateImage, *loudCateImage;
@property (nonatomic, retain) UILabel *nameLabel, *timeLabel, *cellText, *loudCateLabel;
@property (nonatomic, retain) UILabel *payCateDescLabel, *commentLabel, *locationDescLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
