//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Profile.h"
#import "LocationController.h"
#import "SSTextView.h"

@interface HelpSendViewController : UIViewController <UITextViewDelegate, MKReverseGeocoderDelegate>
{
@private
    UITabBarController *helpTabBarController_;
    UITextView *helpTextView_;
    UILabel *numIndicator_;
    UIBarItem *sendBarItem_;
    
    UIActivityIndicatorView *loadingIndicator_;
    
    MKReverseGeocoder *reverseGeocoder_;
    NSString *address_;
    
}

@property (nonatomic, retain) UITabBarController *helpTabBarController;
@property (nonatomic, retain) IBOutlet UITextView *helpTextView;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) IBOutlet UIBarItem *sendBarItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) NSString *address;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)addRewardButtonPressed:(id)sender;
- (void)postHelpTextToRemoteServer;
- (void)parsePosition;
- (void)fakeParsePosition;

@end
