//
//  ProfileViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
{
@private
    NSDictionary *user_;
    UILabel *toHelpIndicator_, *beHelpedIndicator_, *starIndicator_;
    UIView *toHelpView_, *beHelpedView_, *starView_, *descView_;
    UIImageView *avatarImage_;
    UILabel *nameLabel_, *descLabel_;
}

@property (nonatomic, retain) NSDictionary *user;
@property (nonatomic, retain) IBOutlet UILabel *toHelpIndicator, *beHelpedIndicator, *starIndicator;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *descLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet UIView *descView, *toHelpView, *beHelpedView, *starView;

@end
