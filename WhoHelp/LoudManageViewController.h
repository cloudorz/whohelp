//
//  LoudManageViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "Profile.h"

@interface LoudManageViewController : UIViewController <UIActionSheetDelegate>
{
@private
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    
    Profile *profile_;
    NSArray *louds_;
    NSMutableArray *buttons_;
}

@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSArray *louds;
@property (nonatomic, retain) NSMutableArray *buttons;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)entryButtonPressed:(id)sender;

- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)warningNotification:(NSString *)message;
- (void)errorNotification:(NSString *)message;
- (void)fetch3Louds;

@end
