//
//  MessageTableViewCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
{
@private
    UIImageView *avatarImage;
    UILabel *contentLabel, *timeLabel;
}

@property (nonatomic, retain) UIImageView *avatarImage;
@property (nonatomic, retain) UILabel *contentLabel, *timeLabel;

@end
