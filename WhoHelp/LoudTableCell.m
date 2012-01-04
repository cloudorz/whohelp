//
//  LoudTableCell.m
//  WhoHelp
//
//  Created by cloud on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoudTableCell.h"
#import "Config.h"

@implementation LoudTableCell

@synthesize avatarImage, nameLabel, timeLabel, cellText, loudCateLabel;
@synthesize payCateDescLabel, payCateImage, loudCateImage, commentLabel, locationDescLabel;

- (void)dealloc
{
    [avatarImage release];
    [nameLabel release];
    [timeLabel release];
    [cellText release];
    [loudCateImage release];
    [loudCateLabel release];
    [payCateImage release];
    [payCateDescLabel release];
    [commentLabel release];
    [locationDescLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        // all params 
        UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
        
//            NSLog(@"print print %f", contentHeight);
    
        // avatar show
        UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrame.png"]] autorelease];
        avatarFrame.frame = CGRectMake(12, 11.5, 35, 36);
        avatarFrame.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:avatarFrame];
        
        avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 35, 35)] autorelease]; // show
        avatarImage.tag = 1;
        avatarImage.opaque = YES;
        avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
//            avatarImage.layer.borderWidth = 1;
//            avatarImage.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
        //avatarImage.backgroundColor = bgGray;

        [self.contentView addSubview:avatarImage];

        // name show
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 12, 140, NAMEFONTSIZE+2)] autorelease]; // show
        nameLabel.tag = 2;
        nameLabel.opaque = YES;
        nameLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
        nameLabel.textAlignment = UITextAlignmentLeft;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
    
        // time description
        timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(248, 12, 60, SMALLFONTSIZE+2)] autorelease]; // show
        timeLabel.tag = 3;
        timeLabel.opaque = YES;
        timeLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.textColor = smallFontColor;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
        //timeLabel.backgroundColor = bgGray;
        UIImageView *timeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time.png"]] autorelease];
        timeImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
        timeImage.backgroundColor = [UIColor clearColor];
        [timeLabel addSubview:timeImage];
    
        [self.contentView addSubview:timeLabel];
        
        // content
        cellText = [[[UILabel alloc] initWithFrame:CGRectMake(58,  12+NAMEFONTSIZE+10, TEXTWIDTH, contentHeight)] autorelease];
        cellText.tag = 4;
        cellText.textAlignment = UITextAlignmentLeft;
        cellText.lineBreakMode = UILineBreakModeWordWrap;
        cellText.numberOfLines = 0;
        cellText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        cellText.opaque = YES;
        cellText.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:cellText];
        
        // loud category color show
        loudCateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 34+NAMEFONTSIZE+contentHeight, 320, 24)];
        loudCateLabel.tag = 5;
        loudCateLabel.backgroundColor = [UIColor orangeColor]; // FIXME let me go
        loudCateLabel.opaque = YES;
        
        payCateDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 0, TEXTWIDTH, 24)];
        payCateDescLabel.tag = 6;
        payCateDescLabel.textAlignment = UITextAlignmentLeft;
        payCateDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
        payCateDescLabel.numberOfLines = 1;
        payCateDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        payCateDescLabel.backgroundColor = [UIColor clearColor];
        [loudCateLabel addSubview:payCateDescLabel];
    
        [self.contentView addSubview:loudCateLabel];

        // loud category and pay category image show
        loudCateImage = [[UIImageView alloc] initWithFrame:CGRectMake(13.5, 30+NAMEFONTSIZE+contentHeight, 32, 32)];
        loudCateImage.tag = 7;
        loudCateImage.opaque = YES;
        loudCateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        payCateImage = [[UIImageView alloc] initWithFrame:CGRectMake(3.5, 3.5, 25, 25)];
        payCateImage.tag = 8;
        payCateImage.backgroundColor = [UIColor clearColor];
        
        [loudCateImage addSubview:payCateImage];
        [self.contentView addSubview:loudCateImage];
        
        // comment infomation
        commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(268, 69+NAMEFONTSIZE+contentHeight, 70, SMALLFONTSIZE+2)] autorelease]; // show
        commentLabel.tag = 9;
        commentLabel.opaque = YES;
        commentLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        commentLabel.textAlignment = UITextAlignmentRight;
        commentLabel.textColor = smallFontColor;
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        //timeLabel.backgroundColor = bgGray;
        UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
        commentImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
        commentImage.backgroundColor = [UIColor clearColor];
        [commentLabel addSubview:commentImage];
        
        [self.contentView addSubview:commentLabel];
        
        // location descrtion
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, 69+NAMEFONTSIZE+contentHeight, 180, SMALLFONTSIZE+2)];
        locationLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
        locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
        locationImage.backgroundColor = [UIColor clearColor];
        [locationLabel addSubview:locationImage];
        
        locationDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 150, SMALLFONTSIZE+2)];
        locationDescLabel.tag = 10;
        locationDescLabel.textAlignment = UITextAlignmentLeft;
        locationDescLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        locationDescLabel.textColor = smallFontColor;
        locationDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
        locationDescLabel.numberOfLines = 1;
        locationDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        locationDescLabel.backgroundColor = [UIColor clearColor];
        [locationLabel addSubview:locationDescLabel];
        
        [self.contentView addSubview:locationLabel];
        
        // bottome line
        UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, NAMEFONTSIZE+TEXTFONTSIZE+SMALLFONTSIZE+78+contentHeight, 320, 1)];
        bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/225.0 alpha:1.0];
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
