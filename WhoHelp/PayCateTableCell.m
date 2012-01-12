//
//  PayCateTableCell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PayCateTableCell.h"

@implementation PayCateTableCell

@synthesize title, logo;

-(void)dealloc
{
    [title release];
    [logo release];

    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UIView *sbv = [[UIView alloc] init];
        sbv.opaque = YES;
        
        UIImageView *right = [[[UIImageView alloc] initWithFrame:CGRectMake(299, 13, 9, 13)] autorelease];
        right.backgroundColor = [UIColor clearColor];
        right.image = [UIImage imageNamed:@"right.png"];

        [sbv addSubview:right];
        self.selectedBackgroundView = sbv;
        [sbv release];
        
        self.logo = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 16, 16)] autorelease];
        self.logo.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.logo];
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake(41, 13, 100, 16)] autorelease];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont boldSystemFontOfSize:15.0f];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview:self.title];
        
        // bottome line
        UIImageView *bottomLine = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 41, 320, 1)] autorelease];
        bottomLine.backgroundColor = [UIColor clearColor];
        bottomLine.image = [UIImage imageNamed:@"sepline.png"];
        bottomLine.opaque = NO;
        [self.contentView addSubview:bottomLine];
    }
    return self;
}

-(void)selectionBeWhite
{
    self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
    [self performSelector:@selector(selectionBeWhite) withObject:nil afterDelay:0.2];

}

@end
