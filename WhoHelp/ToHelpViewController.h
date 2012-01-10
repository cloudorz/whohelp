//
//  ToHelpViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToHelpViewController : UIViewController <UITextViewDelegate>
{
@private
    NSDictionary *loud_;
    NSDictionary *toUser_;
    BOOL isHelp_, isOwner;
    
    UIImageView *avatarImage_;
    UIView *phoneShow_;
    UIButton *phoneButton_;
    
    UITextView *content_;
    UILabel *numIndicator_;
    UILabel *placeholderLabel_;
}

@property (nonatomic, retain) NSDictionary *loud, *toUser;
@property (nonatomic, assign) BOOL isHelp;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet UIView *phoneShow;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) IBOutlet UIButton *phoneButton;
@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, assign) BOOL isOwner;


- (void)fakeSendPost;
- (void)sendPost;

@end
