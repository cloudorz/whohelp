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
@synthesize avatarImage,arrowImage,nameLabel,timeLabel,distanceLabel,bgButton,cellText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(CGFloat)contentHeight
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.contentView.backgroundColor = [UIColor clearColor];
            self.selectionStyle = UITableViewCellSelectionStyleBlue;
            
//            NSLog(@"print print %f", contentHeight);
            
            avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(IMGLEFT, 5, IMGSIZE, IMGSIZE)] autorelease];
            avatarImage.tag = CELLAVATAR;
            avatarImage.opaque = YES;
            avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
            avatarImage.layer.borderWidth = 1;
            avatarImage.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
            //avatarImage.backgroundColor = bgGray;
            [self.contentView addSubview:avatarImage];
            
            bgButton = [[[UIButton alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+LEFTSPACE, 5, TEXTWIDTH+TEXTMLEFTARGIN+TEXTMARGIN+2, contentHeight + BOTTOMSPACE + 10 + NAMEFONTSIZE + SMALLFONTSIZE+2*TEXTMARGIN)] autorelease];
            bgButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            bgButton.tag = CELLBG;
            bgButton.layer.borderWidth = 1;
            bgButton.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0].CGColor;
            bgButton.layer.cornerRadius = 4;
            bgButton.autoresizingMask = UIViewAutoresizingNone;
            bgButton.enabled = NO;
            [self.contentView addSubview:bgButton];
            
            arrowImage = [[[UIImageView alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+2, 5+5+1, 10, 15)] autorelease];
            arrowImage.tag = CELLARROW;
            arrowImage.opaque = YES;
            arrowImage.autoresizingMask = UIViewAutoresizingNone;
           // arrowImage.backgroundColor = bgGray;
            arrowImage.image = [UIImage imageNamed:@"list_arrow.png"];
            [self.contentView addSubview:arrowImage];
            
            nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN, TOPSPACE+TEXTMARGIN, 200, NAMEFONTSIZE+2)] autorelease];
            nameLabel.tag = CELLNAME;
            nameLabel.opaque = YES;
            nameLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
            nameLabel.textAlignment = UITextAlignmentLeft;
            //nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
            nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
            [self.contentView addSubview:nameLabel];
            
            
            cellText = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN,  TOPSPACE+NAMEFONTSIZE+10+TEXTMARGIN, TEXTWIDTH, contentHeight)] autorelease];
            cellText.tag = CELLTEXT;
            cellText.textAlignment = UITextAlignmentLeft;
            cellText.lineBreakMode = UILineBreakModeWordWrap;
            cellText.numberOfLines = 0;
            cellText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
            cellText.opaque = YES;
            [self.contentView addSubview:cellText];
            
            
            // Configure the cell...
            distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN, TEXTMARGIN+TOPSPACE+NAMEFONTSIZE+contentHeight+15, 160, SMALLFONTSIZE)] autorelease];
            distanceLabel.tag = CELLDISTANCE;
            distanceLabel.opaque = YES;
            distanceLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
            distanceLabel.textAlignment = UITextAlignmentLeft;
            distanceLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
            distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
            //distanceLabel.backgroundColor = bgGray;
            [self.contentView addSubview:distanceLabel]; 
            
            timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+LEFTSPACE+75+90, TEXTMARGIN+TOPSPACE+NAMEFONTSIZE+contentHeight+15, TIMELENGTH, SMALLFONTSIZE)] autorelease];
            timeLabel.tag = CELLTIME;
            timeLabel.opaque = YES;
            timeLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
            timeLabel.textAlignment = UITextAlignmentRight;
            timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
            timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
            //timeLabel.backgroundColor = bgGray;
            [self.contentView addSubview:timeLabel];
            
            
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [cellText release];
    [nameLabel release];
    [timeLabel release];
    [distanceLabel release];
    [bgButton release];
    [avatarImage release];
    [arrowImage release];
    [super dealloc];
}

@end
