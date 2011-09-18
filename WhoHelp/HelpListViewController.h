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

#define CELLAVATAR 5
#define CELLNAME 1
#define CELLDISTANCE 2
#define CELLTIME 3
#define CELLTEXT 4

#define TEXTWIDTH 260.0f
#define LEFTSPACE 5.0f
#define BOTTOMSPACE 5.0f
#define TOPSPACE 5.0f
#define RIGHTSPACE 10.0f
#define IMGSIZE 35.0f
#define NAMEFONTSIZE 14.0f
#define SMALLFONTSIZE 9.0f
#define TEXTFONTSIZE 14.0f
#define TIMELENGTH 75.0f

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
