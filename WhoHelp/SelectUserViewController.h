//
//  SelectUserViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrizeHelperViewController.h"

@interface SelectUserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    UITableView *tableView_;
    NSString *loudURN_;
    NSArray *users_;
    PrizeHelperViewController *phvc_;

}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *loudURN;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) PrizeHelperViewController *phvc;

-(void)fetchUserList;
@end
