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
    NSMutableDictionary *curCollection_;
    NSMutableArray *messages_;
    NSString *lastUpdated_;
    NSTimer *timer_;
    BOOL _loadloud;

}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, retain) NSString *lastUpdated;
@property (nonatomic, retain) NSTimer *timer;

- (void)fetchMsgList;
- (void)fetchLoud:(NSString *)urlString;

@end
