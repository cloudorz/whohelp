//
//  PrizeHelperViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrizeHelperViewController : UIViewController <UITextViewDelegate>
{
@private
    NSMutableDictionary *loud_;
    BOOL hasStar_;
    UIButton *selectUserButton_, *turnStarButton_;
    UIImageView *avatar_;
    UITextView *content_;
    UILabel *numIndicator_;
    UILabel *placeholderLabel_;
    NSMutableDictionary *toUser_;
}

@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) NSMutableDictionary *loud, *toUser;
@property (nonatomic, assign) BOOL hasStar;
@property (nonatomic, retain) IBOutlet UIButton *selectUserButton, *turnStarButton;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) UILabel *placeholderLabel;

- (void)sendPrizePost;

@end
