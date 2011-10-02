//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "Profile.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, OHAttributedLabelDelegate>
{
@private
    NSMutableArray *louds_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    Profile *profile_;
    
    NSMutableDictionary *curCollection_;
    NSMutableDictionary *photoCache_;
    NSString *etag_;

}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, readonly) Profile *profile;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, readonly) NSMutableDictionary *photoCache;
@property (nonatomic, retain) NSString *etag;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)fetchLoudList;
- (void)fetchNextLoudList;
- (void)fakeFetchLoudList;
- (NSData *)photoFromUser: (NSDictionary *)user;

@end
