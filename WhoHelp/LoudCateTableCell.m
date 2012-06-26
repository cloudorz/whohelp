//
//  LoudCateTableCell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoudCateTableCell.h"

@implementation LoudCateTableCell

@synthesize title, subtitle, logo, stickPic;

-(void)dealloc
{
    [title release];
    [subtitle release];
    [logo release];
    [stickPic release];
    [super dealloc];
}

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
        
        self.logo = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 24, 24)] autorelease];
        self.logo.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.logo];
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(48, 9, 100, 16)] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont boldSystemFontOfSize:15.0f];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview:self.title];
        
        self.subtitle = [[[UILabel alloc] initWithFrame:CGRectMake(48, 32, 200, 11)] autorelease];
        self.subtitle.backgroundColor = [UIColor clearColor];
        self.subtitle.font = [UIFont systemFontOfSize:10.0f];
        self.subtitle.textColor = [UIColor colorWithRed:150/255.0 green:141/255.0 blue:136/255.0 alpha:1.0];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview:self.subtitle];
        
        UIImageView *tri = [[[UIImageView alloc] initWithFrame:CGRectMake(299, 18, 9, 13)] autorelease];
        tri.backgroundColor = [UIColor clearColor];
        tri.image = [UIImage imageNamed:@"graytri.png"];
        
        [self.contentView addSubview:tri];
        
        self.stickPic = [[[UIImageView alloc] initWithFrame:CGRectMake(316, 1, 4, 52)] autorelease];
        self.stickPic.opaque = YES;
        
        [self.contentView addSubview:self.stickPic];
        
        // bottome line
        UIImageView *bottomLine = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 53, 320, 1)] autorelease];
        bottomLine.backgroundColor = [UIColor clearColor];
        bottomLine.image = [UIImage imageNamed:@"sepline.png"];
        bottomLine.opaque = NO;
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
