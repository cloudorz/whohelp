//
//  DetailLoudViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailLoudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    NSDictionary *loud_, *user_;
    NSData *avatar_;
    
    UITableView *tableview_;
    BOOL isOwner;
    NSDictionary *loudCates_, *payCates_;
}

@property (nonatomic, retain) NSDictionary *loud, *user;
@property (nonatomic, retain) NSData *avatar;
@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain, readonly) NSDictionary *loudCates, *payCates;

-(void)avatarButtonAction:(id)sender;

@end
