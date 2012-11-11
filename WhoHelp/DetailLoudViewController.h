//
//  DetailLoudViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "HPGrowingTextView.h"
#import "AsyncImageView.h"

@interface DetailLoudViewController : UIViewController <HPGrowingTextViewDelegate, EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate>
{
@private
    
    BOOL isOwner;
//    UIButton *helpNumIndicator_, *justLookIndicaotr_;
    
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading, hasPhone;
    NSDictionary *_loudCates, *_statuses;
    
}

@property (nonatomic, strong) NSString *loudLink;
@property (nonatomic, strong) NSMutableDictionary *loudDetail;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *toHelpNumIndicator, *starNumIndicator;
@property (nonatomic, strong) IBOutlet UIView *otherUserView, *myView;
@property (nonatomic, strong) IBOutlet AsyncImageView *avatarImage;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) NSMutableDictionary *curCollection;
@property (nonatomic, strong) NSString *etag;
@property (nonatomic, strong) UITableViewCell *moreCell;
@property (nonatomic, strong) NSMutableDictionary *tapUser;
@property (nonatomic, strong) IBOutlet UIButton *justLookButton1, *justLookButton2, *helpDoneButton, *phoneButton, *sendButton;
@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) NSString *tmpPhoneNum;
@property (nonatomic, strong) NSMutableArray *atUrns;
@property (nonatomic, strong) NSMutableArray *prizeUids;
@property (nonatomic, retain, readonly) NSDictionary *loudCates, *statuses;
@property (strong, nonatomic) UILabel *placeholderLabel;


-(IBAction)avatarButtonAction:(id)sender;

-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

-(void)fetchReplyList;
-(void)fetchNextReplyList;
-(void)deleteLoud;
- (void)updateLoudInfo;
- (void)grapLoudDetail;

@end
