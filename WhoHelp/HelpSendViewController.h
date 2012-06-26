//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZAnnotation.h"

@interface HelpSendViewController : UIViewController <UITextViewDelegate>
{
    BOOL hasWeibo;
}

@property (strong, nonatomic) IBOutlet UITextView *helpTextView;
@property (strong, nonatomic) IBOutlet UILabel *numIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) NSArray *locaiton;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *poi;
@property (strong, nonatomic) NSDictionary *helpCategory;
@property (strong, nonatomic) IBOutlet UIView *uv;
@property (strong, nonatomic) IBOutlet UILabel *poiLabel;
@property (strong, nonatomic) HZAnnotation *ann;


- (void)sendButtonPressed:(id)sender;

- (void)postHelpTextToRemoteServer;

// new

- (void)turnOnSendEnabled;

@end
