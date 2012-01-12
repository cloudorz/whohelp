//
//  HelpSettingViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface HelpSettingViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
@private
    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    UITableView *tableView_;
    
    NSMutableDictionary *curCollection_;
    NSMutableArray *louds_;
    NSString *etag_;
    UITableViewCell *moreCell_;
    NSDictionary *loudCates_;
    
    UIImageView *avatarImage_;
    UILabel *nameLabel_, *toHelpIndicator_, *beHelpedIndicator_, *starIndciator_;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain, readonly) NSDictionary *loudCates;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel, *toHelpIndicator, *beHelpedIndicator, *starIndciator;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;


@end
