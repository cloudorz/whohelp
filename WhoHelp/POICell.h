//
//  POICell.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface POICell : UITableViewCell

@property (strong, nonatomic) UILabel *title, *subTitle;
@property (strong, nonatomic) AsyncImageView *logo;

@end
