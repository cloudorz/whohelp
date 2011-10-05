//
//  HelpDetailViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface HelpDetailViewController : UIViewController
{
@private
    NSDictionary *loud_;
    UILabel *nameLabel_;
    UILabel *locaitonLabel_;
    UILabel *timeLabel_;
    UIImageView *avatarImage_;
    OHAttributedLabel *contentTextLabel_;
    double distance_;
    NSData *avatarData_;
    UITabBarItem *tel_, *sms_;
    
}

@property (nonatomic, retain) NSDictionary *loud;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet OHAttributedLabel *contentTextLabel;
@property (nonatomic, retain) IBOutlet UITabBarItem *tel, *sms;
@property (nonatomic, retain) NSData *avatarData;
@property double distance;

- (BOOL)hidesBottomBarWhenPushed;

@end
