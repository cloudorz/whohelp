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
    NSData *image_;
}

@property (nonatomic, retain, readonly) NSMutableArray *menu;
@property (nonatomic, readonly) Profile *profile;
@property (nonatomic, retain) NSData *image;

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;

@end
