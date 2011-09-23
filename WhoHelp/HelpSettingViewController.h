//
//  HelpSettingViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface HelpSettingViewController : UIViewController <UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
@private
    NSMutableArray *menu_;
    Profile *profile_;
    NSManagedObjectContext *managedObjectContext_;
    NSData *image_;
}

@property (nonatomic, retain, readonly) NSMutableArray *menu;
@property (nonatomic, retain, readonly) Profile *profile;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSData *image;

- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)warningNotification:(NSString *)message;
- (void)errorNotification:(NSString *)message;
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;

@end
