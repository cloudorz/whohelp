//
//  HelpSettingViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "AsyncImageView.h"

@interface HelpSettingViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
{
@private
    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *louds;
@property (nonatomic, strong) NSMutableDictionary *curCollection;
@property (nonatomic, strong) NSString *etag;
@property (nonatomic, strong) UITableViewCell *moreCell;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel, *toHelpIndicator, *beHelpedIndicator, *starIndciator;
@property (nonatomic, strong) IBOutlet AsyncImageView *avatarImage;

- (void)grapUserDetail;

@end
