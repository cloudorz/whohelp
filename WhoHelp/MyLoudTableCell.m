//
//  MyLoudTableCell.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyLoudTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyLoudTableCell

@synthesize contentLabel=_contentLabel;
@synthesize timeLabel=_timeLabel;
@synthesize commentLabel=_commentLabel;

-(void)dealloc
{
    [_contentLabel release];
    [_timeLabel release];
    [_commentLabel release];
    
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
        UIView *replyContentView = [[[UIView alloc] initWithFrame:CGRectMake(12, 10, 296, contentHeight+43)] autorelease];
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
        self.contentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 228, contentHeight)] autorelease];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
        self.contentLabel.textAlignment = UITextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [replyContentView addSubview:self.contentLabel];
        
        
        // reply content view - time show
        UIImageView *timeImage = [[[UIImageView alloc] initWithFrame:CGRectMake(10, contentHeight+21, 9, 9)] autorelease];
        timeImage.image = [UIImage imageNamed:@"time.png"];
        timeImage.backgroundColor = [UIColor clearColor];
        
        [replyContentView addSubview:timeImage];
        
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(23, contentHeight+21, 70, 10)] autorelease];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.opaque = YES;
        self.timeLabel.textAlignment = UITextAlignmentLeft;
        self.timeLabel.font = [UIFont systemFontOfSize:9.0f];
        self.timeLabel.textColor = smallFontColor;
        
        [replyContentView addSubview:self.timeLabel];
        
        // comment infomation
        self.commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(224, contentHeight+21, 50, 10)] autorelease]; // show
        self.commentLabel.opaque = YES;
        self.commentLabel.font = [UIFont systemFontOfSize: 9.0f];
        self.commentLabel.textAlignment = UITextAlignmentRight;
        self.commentLabel.textColor = smallFontColor;
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        //timeLabel.backgroundColor = bgGray;
        UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
        commentImage.frame = CGRectMake(0, 1, 9, 9);
        commentImage.backgroundColor = [UIColor clearColor];
        [self.commentLabel addSubview:commentImage];
        
        [replyContentView addSubview:self.commentLabel];
        
        [self.contentView addSubview:replyContentView];
        
//        
//        UIImageView *tri = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tri.png"]] autorelease];
//        tri.frame = CGRectMake(50, 19, 8, 14);
//        tri.backgroundColor = [UIColor clearColor];
//        tri.opaque = NO;
//        
//        [self.contentView addSubview:tri];
        
        // bottom line
        UILabel *grayLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, contentHeight+63, 320, 1)] autorelease];
        grayLine.opaque = YES;
        grayLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:229/255.0 blue:226/255.0 alpha:1.0];  
        
        [self.contentView addSubview:grayLine];
        
        UILabel *whiteLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, contentHeight+64, 320, 1)] autorelease];
        whiteLine.opaque = YES;
        whiteLine.backgroundColor = [UIColor whiteColor]; 
        
        [self.contentView addSubview:whiteLine];
        
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
