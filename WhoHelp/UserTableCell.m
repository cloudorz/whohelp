//
//  UserTableCell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserTableCell.h"

@implementation UserTableCell

@synthesize avatarImage, name;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *sbv = [[UIView alloc] init];
        sbv.backgroundColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
        sbv.opaque = YES;
        self.selectedBackgroundView = sbv;
        [sbv release];
        
        // avatar show
        self.avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 35, 35)] autorelease]; // show
        self.avatarImage.opaque = YES;
        
        [self.contentView addSubview:self.avatarImage];
        
        UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrame.png"]] autorelease];
        avatarFrame.frame = CGRectMake(12, 10, 35, 36);
        avatarFrame.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:avatarFrame];
        
        // name show
        self.name = [[[UILabel alloc] initWithFrame:CGRectMake(58, 18, 200, 19)] autorelease]; // show

        self.name.opaque = YES;
        self.name.font = [UIFont boldSystemFontOfSize:18];
        self.name.textAlignment = UITextAlignmentLeft;
        self.name.lineBreakMode = UILineBreakModeTailTruncation;
        self.name.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.name];
        
        
        // bottome line
        UILabel *bottomLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, 54, 320, 1)] autorelease];
        bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        bottomLine.opaque = YES;
        [self.contentView addSubview:bottomLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
