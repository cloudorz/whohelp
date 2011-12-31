//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "LocationController.h"
//#import <MapKit/MapKit.h>
//#import "SSTextView.h"

@interface HelpSendViewController : UIViewController <UITextViewDelegate>
{
@private

    UIBarItem *sendBarItem_;
    
    UIActivityIndicatorView *loadingIndicator_;
    
    // new
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
    
}

@property (nonatomic, retain) IBOutlet UITextView *helpTextView;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) IBOutlet UIBarItem *sendBarItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UILabel *duetimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *wardLabel;
@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) IBOutlet UIButton *duetimeButton;
@property (nonatomic, retain) IBOutlet UIButton *wardButton;

// new 
@property (nonatomic, retain) NSDictionary *helpCategory;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) NSDate *duetime;
@property (nonatomic, retain) NSDictionary *wardCategory;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;

- (void)postHelpTextToRemoteServer;
- (void)fakePostHelpTextToRemoteServer;

// new
- (IBAction)duetimeAction:(id)sender;
- (IBAction)wadAction:(id)sender;
- (IBAction)renrenAction:(id)sender;
- (IBAction)weiboAction:(id)sender;
- (IBAction)doubanAction:(id)sender;

@end
