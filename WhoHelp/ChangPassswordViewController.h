//
//  ChangPassswordViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "Profile.h"

@interface ChangPassswordViewController : UIViewController <UITextFieldDelegate>
{
@private
    UITextField *oldPassword_;
    UITextField *newPassword_;
    UITextField *repeatPassword_;
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    Profile *profile_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic ,retain) IBOutlet UITextField *oldPassword;
@property (nonatomic ,retain) IBOutlet UITextField *newPassword;
@property (nonatomic ,retain) IBOutlet UITextField *repeatPassword;
@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Profile *profile;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)doneEditing:(id)sender;

- (void)postPasswordInfo: (NSMutableDictionary *)passwordInfo;

@end
