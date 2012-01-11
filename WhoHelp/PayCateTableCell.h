//
//  PayCateTableCell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayCateTableCell : UITableViewCell
{
@private
    UILabel *title;
    UIImageView *logo;
}

@property (nonatomic, retain) UILabel  *title;
@property (nonatomic, retain) UIImageView *logo;

@end
