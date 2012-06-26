//
//  LoudCateTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoudCateTableCell : UITableViewCell
{
@private
    UILabel *title, *subtitle;
    UIImageView *logo, *stickPic;
}

@property (nonatomic, retain) UILabel  *title, *subtitle;
@property (nonatomic, retain) UIImageView *logo, *stickPic;

@end
