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

}


@property (strong, nonatomic) NSMutableArray *louds;
@property (strong, nonatomic) NSMutableDictionary *curCollection;
@property (strong, nonatomic) NSString *etag;
@property (strong, nonatomic) UITableViewCell *moreCell;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *lastUpdated;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)fetchLoudList;
- (void)fetchNextLoudList;
- (void)fetchUpdatedInfo;
//- (void)fakeFetchLoudList;

@end
