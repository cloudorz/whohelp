//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpSendViewController : UIViewController <UITextViewDelegate>


@property (strong, nonatomic) IBOutlet UITextView *helpTextView;
@property (strong, nonatomic) IBOutlet UILabel *numIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) IBOutlet UINavigationItem *myNavigationItem;
@property (strong, nonatomic) NSArray *locaiton;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *poi;


- (void)sendButtonPressed:(id)sender;

- (void)postHelpTextToRemoteServer;

// new

- (void)turnOnSendEnabled;

@end
