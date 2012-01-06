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
        //self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *sbv = [[UIView alloc] init];
        sbv.backgroundColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
        sbv.opaque = YES;
        self.selectedBackgroundView = sbv;
        [sbv release];
        
        // all params 
        UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
        
    
        // avatar show
        avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 35, 35)] autorelease]; // show
        avatarImage.tag = 1;
        avatarImage.opaque = YES;
        avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;

        [self.contentView addSubview:avatarImage];
        
        UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrame.png"]] autorelease];
        avatarFrame.frame = CGRectMake(12, 12, 35, 36);
        avatarFrame.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:avatarFrame];

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
    
        [self.contentView addSubview:timeLabel];
        
        // content
        cellText = [[[UILabel alloc] initWithFrame:CGRectMake(58,  12+NAMEFONTSIZE+10, TEXTWIDTH, contentHeight)] autorelease];
        cellText.tag = 4;
        cellText.textAlignment = UITextAlignmentLeft;
        cellText.lineBreakMode = UILineBreakModeWordWrap;
        cellText.numberOfLines = 0;
        cellText.font = [UIFont systemFontOfSize:TEXTFONTSIZE];
        cellText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        cellText.opaque = YES;
        cellText.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:cellText];
        
        // loud category color show
        loudCateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 34+NAMEFONTSIZE+contentHeight, 320, 24)] autorelease];
        loudCateLabel.tag = 5;
        loudCateLabel.backgroundColor = [UIColor orangeColor]; // FIXME let me go
        loudCateLabel.opaque = YES;
        
        payCateDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 0, TEXTWIDTH, 24)] autorelease];
        payCateDescLabel.tag = 6;
        payCateDescLabel.textAlignment = UITextAlignmentLeft;
        payCateDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
        payCateDescLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
        payCateDescLabel.textColor = [UIColor whiteColor];
        payCateDescLabel.numberOfLines = 1;
        payCateDescLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingNone;
        payCateDescLabel.backgroundColor = [UIColor clearColor];
        [loudCateLabel addSubview:payCateDescLabel];
    
        [self.contentView addSubview:loudCateLabel];

        // loud category and pay category image show
        loudCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(13, 30+NAMEFONTSIZE+contentHeight, 32, 32)] autorelease];
        loudCateImage.tag = 7;
        loudCateImage.opaque = YES;
        loudCateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        payCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 24, 24)] autorelease];
        payCateImage.tag = 8;
        payCateImage.backgroundColor = [UIColor clearColor];
        
        [loudCateImage addSubview:payCateImage];
        [self.contentView addSubview:loudCateImage];
        
        // comment infomation
        commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(258, 69+NAMEFONTSIZE+contentHeight, 50, SMALLFONTSIZE+2)] autorelease]; // show
        commentLabel.tag = 9;
        commentLabel.opaque = YES;
        commentLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        commentLabel.textAlignment = UITextAlignmentRight;
        commentLabel.textColor = smallFontColor;
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        //timeLabel.backgroundColor = bgGray;
        UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
        commentImage.frame = CGRectMake(0, 1, SMALLFONTSIZE, SMALLFONTSIZE);
        commentImage.backgroundColor = [UIColor clearColor];
        [commentLabel addSubview:commentImage];
        
        [self.contentView addSubview:commentLabel];
        
        // location descrtion
        UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 69+NAMEFONTSIZE+contentHeight, 180, SMALLFONTSIZE+2)] autorelease];
        locationLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
        locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
        locationImage.backgroundColor = [UIColor clearColor];
        [locationLabel addSubview:locationImage];
        
        locationDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 150, SMALLFONTSIZE+2)] autorelease];
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
        UILabel *bottomLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, NAMEFONTSIZE+TEXTFONTSIZE+SMALLFONTSIZE+78-10+contentHeight, 320, 1)] autorelease];
        bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        bottomLine.opaque = YES;
        [bottomLine setAlpha:1.0];
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
