//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EGORefreshTableHeaderView.h"
#import "Profile.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "LoudTableCell.h"

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, OHAttributedLabelDelegate>
{
@private
    NSMutableArray *louds_, *myLouds_, *tmpList_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL _sing;
    BOOL _mylist;
    
    NSMutableDictionary *curCollection_;
    NSMutableDictionary *photoCache_;
    NSString *etag_, *userEtag_, *lastUpdated_;
    UITableViewCell *moreCell_;
    
    SystemSoundID soudObject_;
    CFURLRef soundFileURLRef;
    
    NSDictionary *tapUser_;
    NSString *tapLoudLink_;
    NSIndexPath *tapIndexPath_;
    
    NSTimer *timer_;

}

@property (nonatomic, retain) NSMutableArray *louds, *myLouds, *tmpList;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, readonly) NSMutableDictionary *photoCache;
@property (nonatomic, retain) NSString *etag, *userEtag, *lastUpdated;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain) NSDictionary *tapUser;
@property (nonatomic, retain) NSIndexPath *tapIndexPath;
@property (nonatomic, retain) NSString *tapLoudLink;
@property (nonatomic, retain) NSTimer *timer;
@property (readonly) SystemSoundID soudObject;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

- (void)fetchLoudList;
- (void)fetch3Louds;
- (void)fetchNextLoudList;
- (void)fetchUpdatedInfo;
- (void)fakeFetchLoudList;
- (NSData *)photoFromUser: (NSDictionary *)user;
- (void)setPhotoAsync: (NSDictionary *)args;

@end
