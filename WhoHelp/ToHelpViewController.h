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
    BOOL isHelp_;
    
    UIImageView *avatarImage_;
    UIView *phoneShow_;
    UIImageView *phoneImage_;
    
    UITextView *content_;
    UILabel *numIndicator_;
    UILabel *placeholderLabel_;
}

@property (nonatomic, retain) NSDictionary *loud;
@property (nonatomic, assign) BOOL isHelp;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage, *phoneImage;
@property (nonatomic, retain) IBOutlet UIView *phoneShow;
@property (nonatomic, retain) IBOutlet UITextView *content;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) UILabel *placeholderLabel;


- (void)fakeSendPost;
- (void)sendPost;

@end
