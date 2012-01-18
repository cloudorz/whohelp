//
//  HelpPrizeViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface HelpPrizeViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
@private
    UITableView *tableView_;

    EGORefreshTableHeaderView *_refreshHeaderView;

    BOOL _reloading;
    
    NSMutableDictionary *curCollection_;
    NSMutableArray *prizes_;
    NSString *etag_;
    UITableViewCell *moreCell_;
    
    UIView *sectionView_;
    UILabel *helpotherIndicator_, *goodjosIndicator_;
    NSString *lastUpdated;
    NSTimer *timer_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, retain) NSMutableArray *prizes;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain) IBOutlet UILabel *helpotherIndicator, *goodjosIndicator;
@property (nonatomic, retain) IBOutlet UIView *sectionView;
@property (nonatomic, retain) NSString *lastUpdated;
@property (nonatomic, retain) NSTimer *timer;

-(void)fetchPrizeList;
-(void)fetchNextPrizeList;

@end
