//
//  ReplyTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyTableCell : UITableViewCell
{
@private
    UIImageView *avatarImage, *phoneLogo;
    UILabel *contentLabel, *timeLabel, *locationLabel;
    UIButton *button;
}

@property (nonatomic, retain) UIImageView *avatarImage, *phoneLogo, *starLogo;
@property (nonatomic, retain) UILabel *contentLabel, *timeLabel, *locationLabel;
@property (nonatomic, retain) UIButton *button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
