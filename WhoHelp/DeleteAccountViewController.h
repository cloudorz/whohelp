//
//  DeleteAccountViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "Profile.h"

@interface DeleteAccountViewController : UIViewController
{
@private
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    
    UITextField *password_;
    Profile *profile_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Profile *profile;

- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)warningNotification:(NSString *)message;
- (void)errorNotification:(NSString *)message;

- (void)delAccount: (NSMutableDictionary *)passwordInfo;
- (void)delAccount2;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end
