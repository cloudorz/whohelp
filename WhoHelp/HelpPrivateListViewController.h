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
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading, _loadloud;

}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *curCollection;
@property (nonatomic, strong) NSString *lastUpdated;
@property (nonatomic, strong) UITableViewCell *moreCell;
@property (nonatomic, strong) NSString *etag;

- (void)fetchMsgList;
- (void)fetchNextMsgList;

@end
