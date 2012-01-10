//
//  UserTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTableCell : UITableViewCell
{
@private
    UIImageView *avatarImage;
    UILabel *name;
}

@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UIImageView *avatarImage;

@end
