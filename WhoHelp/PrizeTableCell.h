//
//  PrizeTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrizeTableCell : UITableViewCell
{
@private
    UIImageView *avatarImage, *starLogo;
    UILabel *contentLabel, *timeLabel;
    UIButton *button;
}

@property (nonatomic, retain) UIImageView *avatarImage, *starLogo;
@property (nonatomic, retain) UILabel *contentLabel, *timeLabel;
@property (nonatomic, retain) UIButton *button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
