//
//  ProfileViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ProfileViewController : UIViewController


@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSString *userLink;
@property (nonatomic, strong) IBOutlet UILabel *toHelpIndicator, *beHelpedIndicator, *starIndicator;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel, *descLabel;
@property (nonatomic, strong) IBOutlet AsyncImageView *avatarImage;
@property (nonatomic, strong) IBOutlet UIView *descView, *toHelpView, *beHelpedView, *starView;

- (void)grapUserDetail;

@end
