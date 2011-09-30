//
//  HelpListViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpListViewController.h"
#import "HelpDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"

// fix the get location bug
@implementation CLLocationManager (TemporaryHack)

- (void)hackLocationFix
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:42 longitude:-50];
    [[self delegate] locationManager:self didUpdateToLocation:location fromLocation:nil];
}

- (void)startUpdatingLocation
{
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}

- (void)hackHeadingFix
{
    NSString *heading = [NSString stringWithString:@"Somewhere that direction-ish!"];
    [[self delegate] locationManager:self didUpdateHeading:(id)heading];
}

- (void)startUpdatingHeading
{
    [self performSelector:@selector(hackHeadingFix) withObject:nil afterDelay:0.1];
}

@end


@interface HelpListViewController (Private)
- (void)fetchLoudList;
@end


@implementation HelpListViewController

@synthesize profiles=profiles_;
@synthesize louds=louds_;
@synthesize locationIsWork=locationIsWork_;
@synthesize curCollection=curCollection_;

- (CLLocationManager *) locationManager
{
    if (locationManager_ == nil){
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.delegate = self;
    }
    return locationManager_;
}

- (CLLocation *)curLocation
{
    if (self.locationIsWork){
        //return self.locationManager.location;
        // FIXME now is simulator
        return [[[CLLocation alloc] initWithLatitude:30.293461 longitude:120.160904] autorelease];
    }
    // default location the center of Hangzhou
    return [[[CLLocation alloc] initWithLatitude:30.293461 longitude:120.160904] autorelease];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
  
    return managedObjectContext_;
}

- (Profile *)profile
{
    
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isLogin == YES"]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            
            NSManagedObject *res = [mutableFetchResults objectAtIndex:0];
            profile_ = (Profile *)res;
        }
        
    } else {
        // Handle the error FIXME
        NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
    }
    
    [mutableFetchResults release];
    
    return profile_;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load remote data and init tableview
    [self reloadTableViewDataSource];
    [self doneLoadingTableViewData];
    
 	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationIsWork = NO;
    self.tableView.separatorStyle = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    [self.locationManager startUpdatingLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@", @"Shutting down core  location.");
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
    return [self.louds count];
}
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *loud = [self.louds objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"helpEntry%d", [loud objectForKey:@"id"]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CGSize theSize= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];

    UIImageView *avatarImage, *arrowImage;
    UILabel *nameLabel, *timeLabel, *distanceLabel;
    OHAttributedLabel *cellText;
    UIButton *bgButton;
    UIColor *bgGray = self.view.backgroundColor;
    
    if (cell == nil) {

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = bgGray;
        cell.contentView.backgroundColor = bgGray;
        
        
        avatarImage = [[[UIImageView alloc] initWithFrame:CGRectMake(IMGLEFT, 5, IMGSIZE, IMGSIZE)] autorelease];
        avatarImage.tag = CELLAVATAR;
        avatarImage.opaque = YES;
        avatarImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        avatarImage.layer.borderWidth = 1;
        avatarImage.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
        avatarImage.backgroundColor = bgGray;
        [cell addSubview:avatarImage];
        
        bgButton = [[[UIButton alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+LEFTSPACE, 5, TEXTWIDTH+TEXTMLEFTARGIN+TEXTMARGIN+2, theSize.height + BOTTOMSPACE + 10 + NAMEFONTSIZE + SMALLFONTSIZE+2*TEXTMARGIN)] autorelease];
        bgButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        bgButton.tag = CELLBG;
        bgButton.layer.borderWidth = 1;
        bgButton.layer.borderColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0].CGColor;
        bgButton.layer.cornerRadius = 4;
        bgButton.autoresizingMask = UIViewAutoresizingNone;
        bgButton.enabled = NO;
        [cell addSubview:bgButton];
        
        arrowImage = [[[UIImageView alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+2, 5+5+1, 10, 15)] autorelease];
        arrowImage.tag = CELLARROW;
        arrowImage.opaque = YES;
        arrowImage.autoresizingMask = UIViewAutoresizingNone;
        arrowImage.backgroundColor = bgGray;
        arrowImage.image = [UIImage imageNamed:@"list_arrow.png"];
        [cell addSubview:arrowImage];
        
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN, TOPSPACE+TEXTMARGIN, 75, NAMEFONTSIZE+2)] autorelease];
        nameLabel.tag = CELLNAME;
        nameLabel.opaque = YES;
        nameLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
        nameLabel.textAlignment = UITextAlignmentLeft;
        nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        [cell addSubview:nameLabel];
        

        cellText = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN,  TOPSPACE+NAMEFONTSIZE+10+TEXTMARGIN, TEXTWIDTH, theSize.height)] autorelease];
        cellText.tag = CELLTEXT;
        cellText.textAlignment = UITextAlignmentLeft;
        cellText.lineBreakMode = UILineBreakModeWordWrap;
        cellText.numberOfLines = 0;
        cellText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        cellText.opaque = YES;
        [cell addSubview:cellText];
        
        if (nil == [[loud objectForKey:@"user"] objectForKey:@"avatarData"]){
            [[loud objectForKey:@"user"] setObject:[Utils fetchImage:[[loud objectForKey:@"user"] objectForKey:@"avatar_link"]] forKey:@"avatarData"];
        }
        avatarImage.image = [UIImage imageWithData:[[loud objectForKey:@"user"] objectForKey:@"avatarData"]];
        nameLabel.text = [[loud objectForKey:@"user"] objectForKey:@"name"];
        
        NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:[loud objectForKey:@"content"]];
        [attributedString setFont:[UIFont systemFontOfSize:TEXTFONTSIZE]];
        [attributedString setTextColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0]];
        
        NSRange rang = [[loud objectForKey:@"content"] rangeOfString:@"$" options:NSBackwardsSearch];
        if (NSNotFound != rang.location){
            [attributedString setTextColor:[UIColor colorWithRed:111/255.0 green:195/255.0 blue:58/255.0 alpha:1.0] range:NSMakeRange(rang.location, [[loud objectForKey:@"content"] length] - rang.location)];
        }
        cellText.attributedText =attributedString;
        
        
    } else {
        distanceLabel = (UILabel *)[cell.contentView viewWithTag:CELLDISTANCE];
        timeLabel = (UILabel *)[cell.contentView viewWithTag:CELLTIME];
        [distanceLabel removeFromSuperview];
        [timeLabel removeFromSuperview];
        
    }
    
    // Configure the cell...
    distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(TEXTMARGIN+IMGLEFT+IMGSIZE+LEFTSPACE+TEXTMLEFTARGIN, TEXTMARGIN+TOPSPACE+NAMEFONTSIZE+theSize.height+15, 75, SMALLFONTSIZE)] autorelease];
    distanceLabel.tag = CELLDISTANCE;
    distanceLabel.opaque = YES;
    distanceLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    distanceLabel.textAlignment = UITextAlignmentLeft;
    distanceLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
    distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    //distanceLabel.backgroundColor = bgGray;
    [cell addSubview:distanceLabel]; 
    
    timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(IMGLEFT+IMGSIZE+LEFTSPACE+75+90, TEXTMARGIN+TOPSPACE+NAMEFONTSIZE+theSize.height+15, TIMELENGTH, SMALLFONTSIZE)] autorelease];
    timeLabel.tag = CELLTIME;
    timeLabel.opaque = YES;
    timeLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    timeLabel.textAlignment = UITextAlignmentRight;
    timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
    timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    //timeLabel.backgroundColor = bgGray;
    [cell addSubview:timeLabel];

    
    distanceLabel.text = [NSString stringWithFormat:@"%.0f米",[self.curLocation distanceFromLocation:[[[CLLocation alloc] initWithLatitude:[[loud objectForKey:@"lat"] doubleValue] longitude:[[loud objectForKey:@"lon"] doubleValue]] autorelease]]];
    
    timeLabel.text = [Utils descriptionForTime:[Utils stringToTime:[loud objectForKey:@"created"]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    NSDictionary *loud = [self.louds objectAtIndex:indexPath.row];

    CGSize theSize= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return theSize.height + TOPSPACE + BOTTOMSPACE + 15 + NAMEFONTSIZE + SMALLFONTSIZE+2*TEXTMARGIN;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     HelpDetailViewController *detailViewController = [[HelpDetailViewController alloc] initWithNibName:@"HelpDetailViewController" bundle:nil];
     // ...
    NSDictionary *loud= [self.louds objectAtIndex:indexPath.row];
    detailViewController.loud = loud;
    detailViewController.distance = [self.curLocation distanceFromLocation:[[[CLLocation alloc] initWithLatitude:[[loud objectForKey:@"lat"] doubleValue] longitude:[[loud objectForKey:@"lon"] doubleValue]] autorelease]];
     // Pass the selected object to the new view controller.
     
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
     
}

#pragma mark - RESTful request
- (void)fetchLoudList
{
    NSLog(@"%@", @"fetching louds....");
    CLLocationCoordinate2D curloc = self.curLocation.coordinate;
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@?q=position:%f,%f&qs=created desc&st=0&qn=30&ak=%@&tk=%@", LOUD3URI, curloc.latitude, curloc.longitude, APPKEY, self.profile.token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Got louds then processing louds...");
    //NSString *responseString = [request responseString];

    if ([request responseStatusCode] == 200){
        NSData *responseData = [request responseData];
        
        // create the json parser 
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        NSMutableDictionary *collection = [jsonParser objectWithData:responseData];
        [jsonParser release];
        self.curCollection = collection;
        self.louds = [collection objectForKey:@"louds"];
        [self.tableView reloadData];
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"请求服务出错"];
    }

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [Utils warningNotification:@"网络服务请求失败."];
}



#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchLoudList];
    // some more actions here TODO
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - locationmananger delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", @"Core location claims to have a position.");
    self.locationIsWork = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Core locaiton can't get the fix error: %@, %@", error, [error localizedDescription]);
    self.locationIsWork = NO;

    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                NSLog(@"Core location denied");
                break;
            case kCLErrorLocationUnknown:
                NSLog(@"Core location unkown");
                break;
                
            default:
                break;
        }   
    } else {
        // We handle all non-CoreLocation errors here
    }   

}

#pragma mark - dealloc 
- (void)dealloc
{
    [profiles_ release];
    [louds_ release];
    //[managedObjectContext_ release];
    [profile_ release];
    [_refreshHeaderView release];
    [locationManager_ release];
    [curCollection_ release];
    [super dealloc];
}

@end
