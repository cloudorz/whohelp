//
//  POIViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "POIViewController.h"
#import "CustomItems.h"
#import "HZAnnotation.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "NSString+URLEncoding.h"
#import "POICell.h"
#import "Utils.h"

@interface POIViewController ()
-(void)resetCurrentPos;
-(void)grapPoisFromGoogle: (CLLocationCoordinate2D) coordinate;
-(void)grapPoisFromJiePang:(CLLocationCoordinate2D) coordinate;
-(void)rebuildPoiInfos;
@end

@implementation POIViewController
@synthesize myNavigationItem=_myNavigationItem;
@synthesize mapView=_mapView;
@synthesize tableView=_tableView;
@synthesize headerView=_headerView;
@synthesize pois=_pois;
@synthesize annotaions=_annotaions;
@synthesize helpVc=_helpVc;
@synthesize lastCenter=_lastCenter;

-(void)dealloc
{
    [_myNavigationItem release];
    [_mapView release];
    [_tableView release];
    [_headerView release];
    [_pois release];
    [_annotaions release];
    [_helpVc release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.myNavigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                                initBackBarButtonItemWithTarget:self 
                                                action:@selector(backAction:)] autorelease];
    self.myNavigationItem.title = nil;
    self.tableView.tableHeaderView = self.headerView;
    
    self.lastCenter = CLLocationCoordinate2DMake(0.0, 0.0);
    
}

-(void)backAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resetCurrentPos];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return self.pois.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"poiCell";
    POICell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[POICell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } 
    // Configure the cell...
    NSMutableDictionary *poi = [self.pois objectAtIndex:indexPath.row];
    cell.title.text = [poi objectForKey:@"name"];
    cell.subTitle.text = [poi objectForKey:@"vicinity"];
    [cell.logo loadImage:[poi objectForKey:@"icon"]];
    
//    cell.title.text = [poi objectForKey:@"name"];
//    cell.subTitle.text = [poi objectForKey:@"addr"];
//    NSArray *cates = [poi objectForKey:@"categories"];
//    for ( NSDictionary *d in cates) {
//        if ([[d objectForKey:@"is_primary"] intValue] == 1) {
//            [cell.logo loadImage:[@"http://jiepang.com/" stringByAppendingFormat:[d objectForKey:@"icon"]]];
//            break;
//        }
//    }
//    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *poi = [self.pois objectAtIndex:indexPath.row];
    HZAnnotation *ann = [self.annotaions objectForKey:[poi objectForKey:@"id"]];
    [self.mapView selectAnnotation:ann animated:YES];
    
}

# pragma mark map actions
-(IBAction)resetCurrentPosAction:(id)sender
{

    [self resetCurrentPos];
    [self.mapView selectAnnotation:[[self.mapView annotations] objectAtIndex:0] animated:YES ];

}

-(void)resetCurrentPos
{

    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,
                                                               500, 500) animated:YES];
    

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
	static NSString *kMovingAnnotationViewId = @"HZAnnotationView";
	
	MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kMovingAnnotationViewId];
	if (!annotationView) {
		annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMovingAnnotationViewId];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.canShowCallout = YES;
	}
	
	//configure the annotation view 
    if ([[annotation title] isEqualToString:@"当前位置"]) {
        annotationView.image = [UIImage imageNamed:@"symbol-moving-annotation.png"];
    } else {
        annotationView.image = [UIImage imageNamed:@"Pin.png"];
    }
        
	return annotationView;
	
}


# pragma mark map delegate
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"will change region");
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D curPos = mapView.region.center;

    if ([Utils distanceFrom:curPos to:self.lastCenter] > 450) {
        [self grapPoisFromGoogle:curPos];
//        [self grapPoisFromJiePang:curPos];
        self.lastCenter = CLLocationCoordinate2DMake(curPos.latitude, curPos.longitude);
    }
   
}

//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    NSLog(@"select %@", view);
//
//}
//
//- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
//{
//    NSLog(@"dselect %@", view);
//}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

    self.helpVc.ann = view.annotation;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark request from net.
-(void)grapPoisFromGoogle:(CLLocationCoordinate2D) coordinate
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%d&sensor=true&language=zh-CN&key=%@&types=%@", 
                                       coordinate.latitude,
                                       coordinate.longitude,
                                       300,
                                       GKEY, 
                                       [@"accounting|airport|amusement_park|aquarium|art_gallery|atm|bakery|bank|bar|beauty_salon|bicycle_store|book_store|bowling_alley|bus_station|cafe|campground|car_dealer|car_rental|car_repair|car_wash|casino|cemetery|church|city_hall|clothing_store|convenience_store|courthouse|dentist|department_store|doctor|electrician|electronics_store|embassy|establishment|finance|fire_station|florist|food|funeral_home|furniture_store|gas_station|general_contractor|geocode|grocery_or_supermarket|gym|hair_care|hardware_store|health|hindu_temple|home_goods_store|hospital|insurance_agency|jewelry_store|laundry|lawyer|library|liquor_store|local_government_office|locksmith|lodging|meal_delivery|meal_takeaway|mosque|movie_rental|movie_theater|moving_company|museum|night_club|painter|park|parking|pet_store|pharmacy|physiotherapist|place_of_worship|plumber|police|post_office|real_estate_agency|restaurant|roofing_contractor|rv_park|school|shoe_store|shopping_mall|spa|stadium|storage|store|subway_station|synagogue|taxi_stand|train_station|travel_agency|university|veterinary_care|zoo" URLEncodedString]]];
    

    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        
        NSInteger code = [request responseStatusCode];
        
        if (200 == code){
            NSString *response = [request responseString];
            NSMutableDictionary *data = [response JSONValue];

            if ([[data objectForKey:@"status"] isEqualToString:@"OK"]) {
                self.pois = [data objectForKey:@"results"];
                [self rebuildPoiInfos];
                
            }
  
        }
        
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Fetch POI Info: %@", [error localizedDescription]);
    }];
    
    [request startAsynchronous];
    
}

-(void)grapPoisFromJiePang:(CLLocationCoordinate2D) coordinate
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.jiepang.com/v1/discover/hottest_locations?lat=%f&lon=%f&dist=%d&count=%d&source=%@", 
                                       coordinate.latitude,
                                       coordinate.longitude,
                                       3000,
                                       100,
                                       JPAPPID]];
    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        
        NSInteger code = [request responseStatusCode];
        
        if (200 == code){
            NSString *response = [request responseString];
            NSMutableDictionary *data = [response JSONValue];
            
//            if ([[data objectForKey:@"num_items"] intValue] > 0) {
                self.pois = [data objectForKey:@"items"];
                [self rebuildPoiInfos];
                
//            }
            
        }
        
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Fetch POI Info: %@", [error localizedDescription]);
    }];
    
    [request startAsynchronous];
    
}

-(void)rebuildPoiInfos
{
    [self.tableView reloadData];
    if (self.annotaions == nil) {
        self.annotaions = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    if ([self.annotaions count] > 0) {
        [self.mapView removeAnnotations:[self.annotaions allValues]];
        [self.annotaions removeAllObjects];

    }
    
    for (NSMutableDictionary *poi in self.pois) {
        HZAnnotation *place = [[[HZAnnotation alloc] init] autorelease];
        NSMutableDictionary *loc = [[poi objectForKey:@"geometry"] objectForKey:@"location"];
        CLLocationCoordinate2D pp2 = CLLocationCoordinate2DMake([[loc objectForKey:@"lat"] floatValue], [[loc objectForKey:@"lng"] floatValue]);
        place.coordinate = pp2;
        place.title = [poi objectForKey:@"name"];
        place.subtitle = [poi objectForKey:@"vicinity"];
        [self.annotaions setObject:place forKey:[poi objectForKey:@"id"]];
    }
    
//    for (NSMutableDictionary *poi in self.pois) {
//        HZAnnotation *place = [[[HZAnnotation alloc] init] autorelease];
//        CLLocationCoordinate2D pp2 = CLLocationCoordinate2DMake([[poi objectForKey:@"lat"] floatValue], [[poi objectForKey:@"lon"] floatValue]);
//        place.coordinate = pp2;
//        place.title = [poi objectForKey:@"name"];
//        place.subtitle = [poi objectForKey:@"addr"];
//        [self.annotaions setObject:place forKey:[poi objectForKey:@"guid"]];
//    }
    
    [self.mapView addAnnotations:[self.annotaions allValues]];

    
}

@end
