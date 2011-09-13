//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
@private
    NSMutableArray *louds_;
    NSMutableArray *profiles_;
    NSManagedObjectContext *managedObjectContext_;
    NSArray *newLouds_;
    NSArray *discardLouds_;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, retain) NSArray *newLouds;
@property (nonatomic, retain) NSArray *discardLouds;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
