//
//  LoudTableCell.h
//  WhoHelp
//
//  Created by cloud on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoudTableCell : UITableViewCell
{
@private
    UIImageView *avatarImage, *payCateImage, *loudCateImage, *loudCateLabel;
    UILabel *nameLabel, *timeLabel, *cellText;
    UILabel *payCateDescLabel, *commentLabel, *locationDescLabel;
}

@property (nonatomic, retain) UIImageView *avatarImage, *payCateImage, *loudCateImage, *loudCateLabel;
@property (nonatomic, retain) UILabel *nameLabel, *timeLabel, *cellText;
@property (nonatomic, retain) UILabel *payCateDescLabel, *commentLabel, *locationDescLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
