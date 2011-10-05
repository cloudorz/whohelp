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
#import "LoudTableCell.h"

@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;


- (SystemSoundID) soudObject
{
    if (0 == soudObject_){
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("bird"), CFSTR("aif"), NULL);
        AudioServicesCreateSystemSoundID(soundFileURLRef, &soudObject_);
    }
    return soudObject_;
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
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    self.tableView.separatorStyle = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    return [self.louds count] + 1;
}


-(UITableViewCell *)createMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moretag"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UILabel *labelNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];

	if (nil == self.curCollection){
        labelNumber.text = @"正在加载...";
    } else if (nil == [self.curCollection objectForKey:@"next"]){
        labelNumber.text = @"";
    } else {
        labelNumber.text = @"获取更多";
    }
    
	[labelNumber setTag:1];
	labelNumber.backgroundColor = [UIColor clearColor];
	labelNumber.font = [UIFont boldSystemFontOfSize:14];
	[cell.contentView addSubview:labelNumber];
	[labelNumber release];
	
    self.moreCell = cell;
    
    return self.moreCell;	
}


- (UITableViewCell *)creatNormalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *loud = [self.louds objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;

    CellIdentifier = [NSString stringWithFormat:@"helpEntry:%.0f", contentHeight];
    
    LoudTableCell *cell = (LoudTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[LoudTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier height:contentHeight] autorelease];
        
    } 
    // avatar
    cell.avatarImage.image = [UIImage imageWithData:[self photoFromUser:[loud objectForKey:@"user"]]];
    // name
    cell.nameLabel.text = [[loud objectForKey:@"user"] objectForKey:@"name"];
    
    // content
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:[loud objectForKey:@"content"]];
    [attributedString setFont:[UIFont systemFontOfSize:TEXTFONTSIZE]];
    [attributedString setTextColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0]];
    
    NSRange rang = [[loud objectForKey:@"content"] rangeOfString:@"$" options:NSBackwardsSearch];
    if (NSNotFound != rang.location){
        [attributedString setTextColor:[UIColor colorWithRed:111/255.0 green:195/255.0 blue:58/255.0 alpha:1.0] range:NSMakeRange(rang.location, [[loud objectForKey:@"content"] length] - rang.location)];
    }
    
    cell.cellText.attributedText = attributedString;
    
    // distnace
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.0f米",[[LocationController sharedInstance].location distanceFromLocation:[[[CLLocation alloc] initWithLatitude:[[loud objectForKey:@"lat"] doubleValue] longitude:[[loud objectForKey:@"lon"] doubleValue]] autorelease]]];
    [loud setObject:cell.distanceLabel.text forKey:@"distanceInfo"];
    
    if (nil == [loud objectForKey:@"createdTime"]){
        [loud setObject:[Utils stringToTime:[loud objectForKey:@"created"]] forKey:@"createdTime"];
    }
    // date time
    cell.timeLabel.text = [Utils descriptionForTime:[loud objectForKey:@"createdTime"]];
    
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    if (indexPath.row == [self.louds count]) {
		return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else {
		return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    if (indexPath.row < [self.louds count]){
        NSDictionary *loud = [self.louds objectAtIndex:indexPath.row];

        CGSize theSize= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        return theSize.height + TOPSPACE + BOTTOMSPACE + 15 + NAMEFONTSIZE + SMALLFONTSIZE + 2*TEXTMARGIN;
    } else{
        
        return 40.0f;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.louds count]){
        HelpDetailViewController *detailViewController = [[HelpDetailViewController alloc] initWithNibName:@"HelpDetailViewController" bundle:nil];
        
        NSDictionary *loud= [self.louds objectAtIndex:indexPath.row];
        detailViewController.loud = loud;
        detailViewController.avatarData = [[self.photoCache objectForKey:[[loud objectForKey:@"user"] objectForKey:@"id"]] objectForKey:@"photoData"];
        // Pass the selected object to the new view controller.
         
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
     
}

#pragma mark - RESTful request
- (void)fakeFetchLoudList
{
    if ([CLLocationManager locationServicesEnabled]){
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        [self performSelector:@selector(fetchLoudList) withObject:nil afterDelay:2.0];
    } else{
        [Utils warningNotification:@"定位服务未开启, 无法请求数据"];
    }

}

- (void)fetchLoudList
{

    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@?q=position:%f,%f&qs=created desc&st=0&qn=20&ak=%@&tk=%@", SURI, curloc.latitude, curloc.longitude, APPKEY, [ProfileManager sharedInstance].profile.token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
  
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            NSData *responseData = [request responseData];
            
            // create the json parser 
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSMutableDictionary *collection = [jsonParser objectWithData:responseData];
            [jsonParser release];
            
            if (nil != self.curCollection){
                // beep bo
                _sing = YES;
            }
            
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
    }else{
        [Utils warningNotification:@"网络链接错误"];
    }
}


- (void)fetchNextLoudList
{
    if (nil == self.louds || nil == [self.curCollection objectForKey:@"next"]){
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[Utils partURI:[self.curCollection objectForKey:@"next"] queryString:[NSString stringWithFormat:@"ak=%@&tk=%@", APPKEY, [ProfileManager sharedInstance].profile.token]]];
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
        [Utils warningNotification:@"网络链接错误"];
    }
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fakeFetchLoudList];
    // some more actions here TODO
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    if (_sing){
        AudioServicesPlaySystemSound(self.soudObject);
        _sing = NO;
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

- (void)loadNextLoudList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.

    //[self performSelectorInBackground:@selector(fetchNextLoudList) withObject:nil];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self fetchNextLoudList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil != self.curCollection && 
        indexPath.row == [self.louds count] && 
        nil != [self.curCollection objectForKey:@"next"]) 
    {

        [self performSelector:@selector(loadNextLoudList) withObject:nil afterDelay:0.2];
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
    [_refreshHeaderView release];
    [etag_ release];
    [photoCache_ release];
    [curCollection_ release];
    [moreCell_ release];
    AudioServicesDisposeSystemSoundID(soudObject_);
    CFRelease(soundFileURLRef);
    [super dealloc];
}

@end
