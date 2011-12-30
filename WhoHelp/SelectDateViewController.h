//
//  SelectDateViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpSendViewController.h"

@interface SelectDateViewController : UIViewController
{
@private
    UIDatePicker *duetimePicker_;
    HelpSendViewController *hlVC_;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *duetimePicker;
@property (nonatomic, retain) HelpSendViewController *hlVC;

@end
