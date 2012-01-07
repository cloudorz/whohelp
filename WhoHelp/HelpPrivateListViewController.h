//
//  HelpPrivateListViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface HelpPrivateListViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
@private
    UITableView *tableView_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)fetch3Louds;

@end
