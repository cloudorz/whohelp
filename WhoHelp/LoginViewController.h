//
//  LoginViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
@private
    NSManagedObjectContext *managedObjectContext_;
    UIActivityIndicatorView *loadingIndicator_;
    UITextField *phone_;
    UITextField *pass_;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextField *phone;
@property (nonatomic, retain) IBOutlet UITextField *pass;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)forgotPasswordButtonPressed:(id)sender;
- (IBAction)signupButtonPressed:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (void)saveUserInfo:(NSMutableDictionary *) data;
- (void)postUserInfo: (NSMutableDictionary *)userInfo;
- (NSManagedObject *)getProfileByPhone:(NSNumber *)phone;

@end
