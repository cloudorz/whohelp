//
//  HelpDetailViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Loud.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface HelpDetailViewController : UIViewController
{
@private
    Loud *loud_;
    UILabel *nameLabel_;
    UILabel *locaitonLabel_;
    UILabel *timeLabel_;
    UIImageView *avatarImage_;
    OHAttributedLabel *contentTextLabel_;
    double distance_;
}

@property (nonatomic, retain) Loud *loud;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet OHAttributedLabel *contentTextLabel;
@property double distance;

- (NSString *)descriptionForTime:(NSDate *)date;
- (BOOL)hidesBottomBarWhenPushed;

@end
