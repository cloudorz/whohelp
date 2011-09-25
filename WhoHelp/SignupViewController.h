//
//  SignupViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface SignupViewController : UIViewController
{
@private
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    
    UITextField *phone_;
    UITextField *code_;
    UILabel *codeLabel_;
    BOOL checked_;
    NSString *codeString_;
    UIButton *resendButton_;
}

@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *phone;
@property (nonatomic, retain) IBOutlet UITextField *code;
@property (nonatomic, retain) IBOutlet UIButton *resendButton;
@property (nonatomic, retain) NSString *codeString;
@property (nonatomic, retain) IBOutlet UILabel *codeLabel;
@property (nonatomic) BOOL checked;

- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)warningNotification:(NSString *)message;
- (void)errorNotification:(NSString *)message;
- (void)sendSignupCode;
- (NSString *)genRandStringLength:(int)len;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)resendCode:(id)sender;

@end
