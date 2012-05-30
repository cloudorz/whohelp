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

@synthesize contentLabel=_contentLabel;
@synthesize timeLabel=_timeLabel;

-(void)dealloc
{
    [_contentLabel release];
    [_timeLabel release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // all params 
        UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
        
        
        // reply content view
        UIView *replyContentView = [[[UIView alloc] initWithFrame:CGRectMake(12, 10, 296, contentHeight + 35)] autorelease];
        replyContentView.backgroundColor = [UIColor whiteColor];
        replyContentView.opaque = YES;
        // FIXME cost point
        replyContentView.clipsToBounds = NO;
        [replyContentView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [replyContentView.layer setShadowRadius:0.7f];
        [replyContentView.layer setShadowOffset:CGSizeMake(0, 1)];
        [replyContentView.layer setShadowOpacity:0.25f];
        [replyContentView.layer setCornerRadius:5.0f];
        
        // reply content view - content label
        self.contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12, 9, 272, contentHeight)] autorelease];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
        self.contentLabel.textAlignment = UITextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [replyContentView addSubview:self.contentLabel];
        
        
        // reply content view - time show
        UIImageView *timeImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12, contentHeight+17, 9, 9)] autorelease];
        timeImage.image = [UIImage imageNamed:@"time.png"];
        timeImage.backgroundColor = [UIColor clearColor];
        
        [replyContentView addSubview:timeImage];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, contentHeight+17, 70, 10)] autorelease];
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
