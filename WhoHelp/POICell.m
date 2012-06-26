//
//  POICell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "POICell.h"

@implementation POICell

@synthesize title=_title;
@synthesize subTitle=_subTitle;
@synthesize logo=_logo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.logo =  [[[AsyncImageView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)] autorelease];
        
        [self.contentView addSubview:self.logo];
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(44, 7, 270, 16)] autorelease];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont systemFontOfSize:14.0f];
        self.title.textAlignment = UITextAlignmentLeft;
        self.title.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.title];
        
        self.subTitle = [[[UILabel alloc] initWithFrame:CGRectMake(44, 25, 270, 12)] autorelease];
        self.subTitle.textAlignment = UITextAlignmentLeft;
        self.subTitle.textColor = [UIColor grayColor];
        self.subTitle.font = [UIFont systemFontOfSize:10.0f];
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.subTitle];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
