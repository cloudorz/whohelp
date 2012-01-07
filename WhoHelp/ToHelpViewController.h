//
//  ToHelpViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToHelpViewController : UIViewController
{
@private
    NSData *avatar_;
    NSDictionary *user_;
    BOOL isHelp_;
}

@property (nonatomic, retain) NSData *avatar;
@property (nonatomic, retain) NSDictionary *user;
@property (nonatomic, assign) BOOL isHelp;

@end
