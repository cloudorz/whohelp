//
//  LoudTableCell.h
//  WhoHelp
//
//  Created by cloud on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface LoudTableCell : UITableViewCell

@property (nonatomic, strong) AsyncImageView *avatarImage;
@property (nonatomic, strong) UILabel *nameLabel, *timeLabel, *cellText;
@property (nonatomic, strong) UILabel *commentLabel, *locationDescLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
