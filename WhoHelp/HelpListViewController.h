//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EGORefreshTableHeaderView.h"
#import "WhoHelpAppDelegate.h"
#import "Profile.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "Utils.h"

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, OHAttributedLabelDelegate>
{
@private
    NSMutableArray *louds_;
    NSMutableArray *profiles_;
    NSManagedObjectContext *managedObjectContext_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    CLLocationManager *locationManager_;
    BOOL locationIsWork_;
    
    Profile *profile_;
    
    NSMutableDictionary *curCollection_;

}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, readonly) CLLocation *curLocation;
@property (nonatomic, retain, readonly) Profile *profile;
@property (nonatomic, retain) NSMutableDictionary *curCollection;
@property BOOL locationIsWork;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
