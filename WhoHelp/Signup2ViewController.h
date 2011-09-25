//
//  Signup2ViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"


@interface Signup2ViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
@private
    OHAttributedLabel *errorLabel_;
    UIActivityIndicatorView *loadingIndicator_;
    
    NSString *phone_;
    UITextField *name_;
    UITextField *password_;
    UIImageView *avatar_;
    NSData *avatarData_;
}

@property (nonatomic, retain) IBOutlet OHAttributedLabel *errorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) NSData *avatarData;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)takePhoto:(id)sender;

- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)warningNotification:(NSString *)message;
- (void)errorNotification:(NSString *)message;
- (void)postUserInfo;

@end
