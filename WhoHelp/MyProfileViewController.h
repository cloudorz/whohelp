//
//  MyProfileViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MyProfileViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) IBOutlet UIView *appView, *contentView, *mainView;
@property (nonatomic, strong) IBOutlet UITextView *descContentView;
@property (nonatomic, strong) IBOutlet UITextField *nameField, *phoneField;
@property (nonatomic, strong) IBOutlet AsyncImageView *avatarImage;


-(void)uploadImageFromData:(NSData *)avatarData;
-(BOOL)testPhoneNumber:(NSString *)num;
-(void)updateUserInfo;
//- (void)authRequest: (NSString *)path;

@end
