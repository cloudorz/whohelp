//
//  MyProfileViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
@private
    NSData *image_;
    UIView *appView, *contentView, *mainView;
    UIImageView *avatarImage, *doubanImage, *renrenImage, *weiboImage;
    UITextView *descContentView;
    UITextField *nameField, *phoneField;

}

@property (nonatomic, retain) NSData *image;
@property (nonatomic, retain) IBOutlet UIView *appView, *contentView, *mainView;
@property (nonatomic, retain) IBOutlet UITextView *descContentView;
@property (nonatomic, retain) IBOutlet UITextField *nameField, *phoneField;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage, *doubanImage, *renrenImage, *weiboImage;

@end
