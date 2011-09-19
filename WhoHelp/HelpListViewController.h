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

@interface HelpListViewController : UITableViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
{
@private
    NSMutableArray *louds_;
    NSMutableArray *profiles_;
    NSManagedObjectContext *managedObjectContext_;
    
    NSArray *newLouds_;
    NSArray *discardLouds_;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    CLLocationManager *locationManager_;
    BOOL locationIsWork_;
    
}

@property (nonatomic, retain) NSMutableArray *louds;
@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, retain) NSArray *newLouds;
@property (nonatomic, retain) NSArray *discardLouds;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, readonly) CLLocation *curLocation;
@property BOOL locationIsWork;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (NSString *)descriptionForTime:(NSDate *)date;

@end
