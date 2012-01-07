//
//  ProfileViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
{
@private
    NSData *avatar_;
    NSDictionary *user_;
}

@property (nonatomic, retain) NSData *avatar;
@property (nonatomic, retain) NSDictionary *user;

@end
