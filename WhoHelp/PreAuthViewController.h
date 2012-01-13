//
//  PreAuthViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreAuthViewController : UIViewController
{
@private
    UIButton *authLinkDouban_;
    UIButton *authLinkWeibo_;
    UIButton *authLinkRenren_;


}

@property (nonatomic, retain) UIButton *authLinkDouban;
@property (nonatomic, retain) UIButton *authLinkWeibo;
@property (nonatomic, retain) UIButton *authLinkRenren;


- (IBAction)linkToAuthDouban:(id)sender;
- (IBAction)linkToAuthWeibo:(id)sender;
- (IBAction)linkToAuthRenren:(id)sender;

- (void)authRequest: (NSString *)path;

@end
