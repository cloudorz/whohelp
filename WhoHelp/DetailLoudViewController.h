//
//  DetailLoudViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface DetailLoudViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
@private
    NSMutableDictionary *loud_;
    
    UITableView *tableView_;
    BOOL isOwner;
    NSDictionary *loudCates_, *payCates_;
    UILabel *toHelpNumIndicator_, *starNumIndicator_;
//    UIButton *helpNumIndicator_, *justLookIndicaotr_;
    
    UIView *otherUserView_, *myView_;
    UIImageView *avatarImage_;
    UILabel *name_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    
    NSMutableDictionary *curCollection_;
    NSMutableArray *replies_;
    NSString *etag_;
    UITableViewCell *moreCell_;
    
    NSMutableDictionary *tapUser_;
    
    UIButton *justLookButton1, *justLookButton2, *helpDoneButton, *offerHelpButton;
}

@property (nonatomic, retain) NSMutableDictionary *loud;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain, readonly) NSDictionary *loudCates, *payCates;
@property (nonatomic, retain) IBOutlet UILabel *toHelpNumIndicator, *starNumIndicator;
//@property (nonatomic, retain) IBOutlet UIButton *helpNumIndicator, *justLookIndicaotr;
@property (nonatomic, retain) IBOutlet UIView *otherUserView, *myView;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) NSMutableArray *replies;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) UITableViewCell *moreCell;
@property (nonatomic, retain) NSMutableDictionary *tapUser;
@property (nonatomic, retain) IBOutlet UIButton *justLookButton1, *justLookButton2, *helpDoneButton, *offerHelpButton;

-(IBAction)avatarButtonAction:(id)sender;

-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

-(void)fetchReplyList;
-(void)fetchNextReplyList;
-(void)deleteLoud;

@end
