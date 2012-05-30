//
//  PreAuthViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreAuthViewController : UIViewController


@property (nonatomic, strong) IBOutlet UIButton *authLinkDouban;
@property (nonatomic, strong) IBOutlet UIButton *authLinkWeibo;
@property (nonatomic, strong) IBOutlet UIButton *authLinkRenren;
@property (nonatomic, strong) IBOutlet UINavigationItem *myNavigationItem;


- (IBAction)linkToAuthDouban:(id)sender;
- (IBAction)linkToAuthWeibo:(id)sender;
- (IBAction)linkToAuthRenren:(id)sender;

- (void)authRequest: (NSString *)path;

@end
