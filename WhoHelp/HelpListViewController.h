//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoudTableCell.h"

@interface HelpListViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
@private

    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    NSMutableDictionary *curCollection_;
    NSMutableArray *louds_;
    NSString *etag_;
    UITableViewCell *moreCell_;
    NSDictionary *loudCates_, *payCates_;
    UITableView *tableView_;
    NSString *lastUpdated;
    NSTimer *timer_;

}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain, readonly) NSDictionary *loudCates, *payCates;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *lastUpdated;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)fetchLoudList;
- (void)fetchNextLoudList;
- (void)fetchUpdatedInfo;
- (void)fakeFetchLoudList;

@end
