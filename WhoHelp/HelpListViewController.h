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
#import "LoudTableCell.h"
#import "UINavigationBar+CustomImage.h"

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, OHAttributedLabelDelegate>
{
@private
    NSMutableArray *louds_;
    BOOL _reloading;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    NSMutableDictionary *curCollection_;
    NSMutableDictionary *photoCache_;
    NSString *etag_, *userEtag_, *lastUpdated_;
    UITableViewCell *moreCell_;
    
    NSTimer *timer_;

}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, readonly) NSMutableDictionary *photoCache;
@property (nonatomic, retain) NSString *etag, *userEtag, *lastUpdated;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain) NSTimer *timer;


- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)handleAvatarForCell: (LoudTableCell *)cell withUid: (NSString *)uid withImgLink: (NSString *)link;
- (void)handleUserInfoForCell: (LoudTableCell *)cell withLink: (NSDictionary *)userLink;

- (void)fetchLoudList;
- (void)fetchNextLoudList;
- (void)fetchUpdatedInfo;
- (void)fakeFetchLoudList;
- (NSData *)photoFromUser: (NSDictionary *)user;
- (void)setPhotoAsync: (NSDictionary *)args;

@end
