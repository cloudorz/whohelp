//
//  SelectWardViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpSendViewController.h"

@interface SelectWardViewController : UITableViewController <UITextFieldDelegate>
{
@private
    NSArray *wardCategories_;
    HelpSendViewController *hlVC_;
    UITextField *wardTextField_;
}

@property (nonatomic, retain, readonly) NSArray *wardCategories;
@property (nonatomic, retain) HelpSendViewController *hlVC;
@property (nonatomic, retain) UITextField *wardTextField;

@end
