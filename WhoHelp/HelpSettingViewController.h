//
//  HelpSettingViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
@private
    NSMutableArray *menu_;
    NSData *image_;
    UITableView *tableView_;
}

@property (nonatomic, retain, readonly) NSMutableArray *menu;
@property (nonatomic, retain) NSData *image;
@property (nonatomic, retain) IBOutlet UITableView *tableView;


@end
