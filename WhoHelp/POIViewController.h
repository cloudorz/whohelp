//
//  POIViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HelpSendViewController.h"

@interface POIViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationItem *myNavigationItem;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSMutableArray *pois;
@property (strong, nonatomic) NSMutableDictionary *annotaions;
@property (strong, nonatomic) HelpSendViewController *helpVc;
@property (assign, nonatomic) CLLocationCoordinate2D lastCenter;

@end
