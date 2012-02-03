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
        self.avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 35, 35)] autorelease]; // show
        self.avatarImage.tag = 1;
        self.avatarImage.opaque = YES;
        self.avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;

        [self.contentView addSubview:self.avatarImage];
        
        UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrame.png"]] autorelease];
        avatarFrame.frame = CGRectMake(12, 12, 35, 36);
        avatarFrame.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:avatarFrame];

        // name show
        self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 12, 140, NAMEFONTSIZE+2)] autorelease]; // show
        self.nameLabel.tag = 2;
        self.nameLabel.opaque = YES;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
    
        // time description
        self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(248, 12, 60, SMALLFONTSIZE+2)] autorelease]; // show
        self.timeLabel.tag = 3;
        self.timeLabel.opaque = YES;
        self.timeLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        self.timeLabel.textAlignment = UITextAlignmentRight;
        self.timeLabel.textColor = smallFontColor;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
        [self.contentView addSubview:self.timeLabel];
        
        // content
        self.cellText = [[[UILabel alloc] initWithFrame:CGRectMake(58,  12+NAMEFONTSIZE+10, TEXTWIDTH, contentHeight)] autorelease];
        self.cellText.tag = 4;
        self.cellText.textAlignment = UITextAlignmentLeft;
        self.cellText.lineBreakMode = UILineBreakModeWordWrap;
        self.cellText.numberOfLines = 0;
        self.cellText.font = [UIFont systemFontOfSize:TEXTFONTSIZE];
        self.cellText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        self.cellText.opaque = YES;
        self.cellText.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cellText];
        
        // loud category color show
        //loudCateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 34+NAMEFONTSIZE+contentHeight, 320, 24)] autorelease];
        self.loudCateLabel = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 34+NAMEFONTSIZE+contentHeight, 320, 24)] autorelease];
        self.loudCateLabel.tag = 5;
        self.loudCateLabel.backgroundColor = [UIColor clearColor]; // FIXME let me go
        self.loudCateLabel.opaque = YES;
        
        self.payCateDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 0, TEXTWIDTH, 24)] autorelease];
        self.payCateDescLabel.tag = 6;
        self.payCateDescLabel.textAlignment = UITextAlignmentLeft;
        self.payCateDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.payCateDescLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
        self.payCateDescLabel.textColor = [UIColor whiteColor];
        self.payCateDescLabel.numberOfLines = 1;
        self.payCateDescLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingNone;
        self.payCateDescLabel.backgroundColor = [UIColor clearColor];
        [self.loudCateLabel addSubview:self.payCateDescLabel];
    
        [self.contentView addSubview:self.loudCateLabel];

        // loud category and pay category image show
        self.loudCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(13, 30+NAMEFONTSIZE+contentHeight, 32, 32)] autorelease];
        self.loudCateImage.tag = 7;
        self.loudCateImage.opaque = YES;
        self.loudCateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        self.payCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 24, 24)] autorelease];
        self.payCateImage.tag = 8;
        self.payCateImage.backgroundColor = [UIColor clearColor];
        
        [self.loudCateImage addSubview:self.payCateImage];
        [self.contentView addSubview:self.loudCateImage];
        
        // comment infomation
        self.commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(258, 69+NAMEFONTSIZE+contentHeight, 50, SMALLFONTSIZE+2)] autorelease]; // show
        self.commentLabel.tag = 9;
        self.commentLabel.opaque = YES;
        self.commentLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        self.commentLabel.textAlignment = UITextAlignmentRight;
        self.commentLabel.textColor = smallFontColor;
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        
        //timeLabel.backgroundColor = bgGray;
        UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
        commentImage.frame = CGRectMake(0, 1, SMALLFONTSIZE, SMALLFONTSIZE);
        commentImage.backgroundColor = [UIColor clearColor];
        [self.commentLabel addSubview:commentImage];
        
        [self.contentView addSubview:self.commentLabel];
        
        // location descrtion
        UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 69+NAMEFONTSIZE+contentHeight, 180, SMALLFONTSIZE+2)] autorelease];
        locationLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
        locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE-1, SMALLFONTSIZE);
        locationImage.backgroundColor = [UIColor clearColor];
        [locationLabel addSubview:locationImage];
        
        self.locationDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 150, SMALLFONTSIZE+2)] autorelease];
        self.locationDescLabel.tag = 10;
        self.locationDescLabel.textAlignment = UITextAlignmentLeft;
        self.locationDescLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
        self.locationDescLabel.textColor = smallFontColor;
        self.locationDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.locationDescLabel.numberOfLines = 1;
        self.locationDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        self.locationDescLabel.backgroundColor = [UIColor clearColor];
        [locationLabel addSubview:self.locationDescLabel];
        
        [self.contentView addSubview:locationLabel];
        
        // bottome line
        UIImageView *bottomLine = [[[UIImageView alloc] initWithFrame:CGRectMake(0, NAMEFONTSIZE+TEXTFONTSIZE+SMALLFONTSIZE+78-10+contentHeight, 320, 1)] autorelease];
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
