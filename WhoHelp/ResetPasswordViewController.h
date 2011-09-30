//
//  ResetPasswordViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface ResetPasswordViewController : UIViewController
{
@private
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    
    UITextField *phone_;
}

@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *phone;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (void)resetPasswordInfo: (NSString *)phone;

@end
