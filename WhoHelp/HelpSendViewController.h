//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpSendViewController : UIViewController <UITextViewDelegate>
{
@private
    
    UIActivityIndicatorView *loadingIndicator_;
    NSDictionary *helpCategory_;
    
    UIImageView *avatar_;
    UILabel *placeholderLabel_;
    UILabel *numIndicator_;
    UILabel *duetimeLabel_;
    UILabel *wardLabel_;
    UITextView *helpTextView_;
    NSDate *duetime_;
    NSDictionary *wardCategory_;
    UIButton *duetimeButton_;
    UIButton *wardButton_;
    NSString *wardText_;
    
    BOOL hasRenren, hasDouban, hasWeibo;
    
    
}

@property (nonatomic, retain) IBOutlet UITextView *helpTextView;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UILabel *duetimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *wardLabel;
@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) IBOutlet UIButton *duetimeButton;
@property (nonatomic, retain) IBOutlet UIButton *wardButton;
@property (nonatomic, retain) NSDictionary *helpCategory;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) NSDate *duetime;
@property (nonatomic, retain) NSDictionary *wardCategory;
@property (nonatomic, retain) NSString *wardText;

- (void)sendButtonPressed:(id)sender;

- (void)postHelpTextToRemoteServer;
- (void)fakePostHelpTextToRemoteServer;

// new
- (IBAction)duetimeAction:(id)sender;
- (IBAction)wadAction:(id)sender;
- (IBAction)renrenAction:(id)sender;
- (IBAction)weiboAction:(id)sender;
- (IBAction)doubanAction:(id)sender;

- (void)turnOnSendEnabled;

@end
