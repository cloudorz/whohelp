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
#import "Utils.h"
#import "LocationController.h"
#import "ProfileManager.h"

@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;


- (Profile *)profile
{
    if (nil == profile_){
        profile_ = [[ProfileManager sharedInstance] profile];
    }
    
    return profile_;
}

- (NSMutableDictionary *)photoCache
{
    if (nil == photoCache_){
        photoCache_ = [[NSMutableDictionary alloc] init];
    }
    return photoCache_;
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
 	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    // load remote data and init tableview
    [self fakeFetchLoudList];

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
    self.tableView.separatorStyle = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    //[[LocationController sharedInstance].locationManager startUpdatingLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[[LocationController sharedInstance].locationManager stopUpdatingLocation];
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
    NSMutableDictionary *loud = [self.louds objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"helpEntry%@", [loud objectForKey:@"id"]];
    
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
        
        avatarImage.image = [UIImage imageWithData:[self photoFromUser:[loud objectForKey:@"user"]]];
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

    distanceLabel.text = [NSString stringWithFormat:@"%.0f米",[[LocationController sharedInstance].location distanceFromLocation:[[[CLLocation alloc] initWithLatitude:[[loud objectForKey:@"lat"] doubleValue] longitude:[[loud objectForKey:@"lon"] doubleValue]] autorelease]]];
    [loud setObject:distanceLabel.text forKey:@"distanceInfo"];
    
    if (nil == [loud objectForKey:@"createdTime"]){
        [loud setObject:[Utils stringToTime:[loud objectForKey:@"created"]] forKey:@"createdTime"];
    }
    timeLabel.text = [Utils descriptionForTime:[loud objectForKey:@"createdTime"]];
    
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
    
    NSDictionary *loud= [self.louds objectAtIndex:indexPath.row];
    detailViewController.loud = loud;
    detailViewController.avatarData = [[self.photoCache objectForKey:[[loud objectForKey:@"user"] objectForKey:@"id"]] objectForKey:@"photoData"];
    // Pass the selected object to the new view controller.
     
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
     
}

#pragma mark - RESTful request
- (void)fakeFetchLoudList
{
    [[LocationController sharedInstance].locationManager startUpdatingLocation];
    [self performSelector:@selector(fetchLoudList) withObject:nil afterDelay:1.5];
}

- (void)fetchLoudList
{

    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@?q=position:%f,%f&qs=created desc&st=0&qn=20&ak=%@&tk=%@", SURI, curloc.latitude, curloc.longitude, APPKEY, self.profile.token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
  
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    [request setDelegate:self];
    [request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{

    //NSString *responseString = [request responseString];

    if ([request responseStatusCode] == 200){
        NSData *responseData = [request responseData];

        // create the json parser 
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSMutableDictionary *collection = [jsonParser objectWithData:responseData];
        [jsonParser release];
        
        self.curCollection = collection;
        self.louds = [collection objectForKey:@"louds"];
        self.etag = [[request responseHeaders] objectForKey:@"Etag"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else if (304 == [request responseStatusCode]) {
        // do Nothing now.
        //NSLog(@"the louds list not modified.");
    }else{
        [Utils warningNotification:@"服务器异常返回"];
    }

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [Utils warningNotification:@"网络服务请求失败."];
}


- (void)fetchNextLoudList
{
    if (nil == self.louds || nil == [self.curCollection objectForKey:@"next"]){
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[Utils partURI:[self.curCollection objectForKey:@"next"] queryString:[NSString stringWithFormat:@"ak=%@&tk=%@", APPKEY, self.profile.token]]];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            
            NSData *responseData = [request responseData];
            // create the json parser 
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSMutableDictionary *collection = [jsonParser objectWithData:responseData];
            [jsonParser release];
            
            self.curCollection = collection;
            [self.louds addObjectsFromArray:[collection objectForKey:@"louds"]];
    
            // reload the tableview data
            [self.tableView reloadData];
 
        } else if (400 == [request responseStatusCode]) {
            [Utils warningNotification:@"参数错误"];
        } else{
            [Utils warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [Utils warningNotification:@"请求服务错误"];
    }
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fakeFetchLoudList]; // may be go
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


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.louds count] - 1) {
        
        UIView *footSpinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        UIActivityIndicatorView *loadView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadView.hidesWhenStopped = YES;
        [loadView stopAnimating];
        [footSpinnerView addSubview:loadView];
        loadView.center = CGPointMake(160, 15);
        [loadView release];
        [self.tableView.tableFooterView addSubview:footSpinnerView];
        
        [self fetchNextLoudList];
        
    } else {
        self.tableView.tableFooterView = nil;
    }
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

#pragma mark - get photo from cahce or remote
- (NSData *)photoFromUser: (NSDictionary *)user
{
    NSMutableDictionary *info = [self.photoCache objectForKey:[user objectForKey:@"id"]];
    if (nil == info){
        info = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    if (nil != [info objectForKey:@"expir"] && abs([[info objectForKey:@"expir"] timeIntervalSinceNow]) < 6*60){
        return [info objectForKey:@"photoData"];
    }
    
    NSURL *url = [NSURL URLWithString:[user objectForKey:@"avatar_link"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != [info objectForKey:@"last"]){
        [request addRequestHeader:@"If-Modified-Since" value:[info objectForKey:@"last"]];
    }
    [request startSynchronous];


    NSError *error = [request error];
    if (!error){
        [info setObject:[[request responseHeaders] objectForKey:@"Last-Modified"] forKey:@"last"];
        [info setObject:[NSDate date] forKey:@"expir"];
        if (200 == [request responseStatusCode]) {
            
            [info setObject:[request responseData] forKey:@"photoData"];
        } 
        
        [self.photoCache setObject:info forKey:[user objectForKey:@"id"]];
        
        return [info objectForKey:@"photoData"];
    } else {
        [Utils warningNotification:@"网络链接错误"];
    }

    return nil;
    
}

#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [profile_ release];
    [_refreshHeaderView release];
    [etag_ release];
    [photoCache_ release];
    [curCollection_ release];
    [super dealloc];
}

@end
