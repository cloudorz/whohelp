//
//  MessageTableViewCell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MessageTableViewCell

@synthesize  contentLabel, timeLabel, avatarImage;

-(void)dealloc
{
    [contentLabel release];
    [timeLabel release];
    [avatarImage release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // all params 
        UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
        
        
        // reply content view
        UIView *replyContentView = [[[UIView alloc] initWithFrame:CGRectMake(12, 10, 296, 47)] autorelease];
        replyContentView.backgroundColor = [UIColor whiteColor];
        replyContentView.opaque = YES;
        // FIXME cost point
        replyContentView.clipsToBounds = NO;
        [replyContentView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [replyContentView.layer setShadowRadius:0.7f];
        [replyContentView.layer setShadowOffset:CGSizeMake(0, 1)];
        [replyContentView.layer setShadowOpacity:0.25f];
        [replyContentView.layer setCornerRadius:5.0f];
        
        UIImageView *tri = [[[UIImageView alloc] initWithFrame:CGRectMake(275, 17, 9, 13)] autorelease];
        tri.backgroundColor = [UIColor clearColor];
        tri.image = [UIImage imageNamed:@"graytri.png"];
        
        [replyContentView addSubview:tri];
        
        // about avatar image 
        self.avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 35, 35)] autorelease];
        self.avatarImage.opaque = YES;
        
        [replyContentView addSubview:self.avatarImage];
        
        
        UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrame.png"]] autorelease];
        avatarFrame.frame = CGRectMake(6, 6, 35, 36);
        avatarFrame.backgroundColor = [UIColor clearColor];
        [replyContentView addSubview:avatarFrame];
        
        // reply content view - content label
        self.contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(51, 9, 200, 15)] autorelease];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
        self.contentLabel.textAlignment = UITextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [replyContentView addSubview:self.contentLabel];
        
        
        // reply content view - time show
        UIImageView *timeImage = [[[UIImageView alloc] initWithFrame:CGRectMake(51, 32, 9, 9)] autorelease];
        timeImage.image = [UIImage imageNamed:@"time.png"];
        timeImage.backgroundColor = [UIColor clearColor];
        
        [replyContentView addSubview:timeImage];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(64, 32, 70, 10)] autorelease];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.opaque = YES;
        self.timeLabel.textAlignment = UITextAlignmentLeft;
        self.timeLabel.font = [UIFont systemFontOfSize:9.0f];
        self.timeLabel.textColor = smallFontColor;
        
        [replyContentView addSubview:self.timeLabel];

        
        [self.contentView addSubview:replyContentView];
         
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
