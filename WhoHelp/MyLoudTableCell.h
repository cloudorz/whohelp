//
//  MyLoudTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLoudTableCell : UITableViewCell
{
@private
    UIImageView *logoImage;
    UILabel *contentLabel, *timeLabel, *commentLabel;
}

@property (nonatomic, retain) UIImageView *logoImage;
@property (nonatomic, retain) UILabel *contentLabel, *timeLabel, *commentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight;

@end
