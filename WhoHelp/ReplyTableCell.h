//
//  ReplyTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ReplyTableCell : UITableViewCell

@property (nonatomic, strong) UIImageView *phoneLogo, *starLogo;
@property (nonatomic, strong) AsyncImageView *avatarImage;
@property (nonatomic, strong) UILabel *contentLabel, *timeLabel, *locationLabel;
@property (nonatomic, strong) UIButton *button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
