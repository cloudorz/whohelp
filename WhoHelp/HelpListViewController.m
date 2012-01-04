//
//  HelpListViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpListViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"
#import "LocationController.h"
#import "ProfileManager.h"
#import "WhiteNavigationBar.h"
// custom
#import "NSString+URLEncoding.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "DetailLoudViewController.h"
#import "UserManager.h"


@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;
@synthesize timer=timer_;

#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [_refreshHeaderView release];
    [etag_ release];
    [curCollection_ release];
    [timer_ release];
    [super dealloc];
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
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
                                           initWithFrame:CGRectMake(0.0f, 
                                                                    0.0f - self.tableView.bounds.size.height, 
                                                                    self.view.frame.size.width, 
                                                                    self.tableView.bounds.size.height)
                                           ];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
    //self.navigationItem.title = @"附近的求助";
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 5, 220, 30)] autorelease];
    label.text = @"附近的求助";
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.titleView = label;
    
    // table view header view
    
//    UIImageView *headerImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)] autorelease];
//    headerImage.image = [UIImage imageNamed:@"tableheader.png"];
//    headerImage.opaque = YES;
//    
//    self.tableView.tableHeaderView = headerImage;
//    
//    UIImageView *navHeaderImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navheader.png"]] autorelease];
//    //navHeaderImage.image = ;
//    navHeaderImage.frame = CGRectMake(0, 0, 320, 49);
//    navHeaderImage.opaque = YES;
//    
//    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 5, 220, 30)] autorelease];
//    label.text = @"附近的求助";
//    label.textAlignment = UITextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:18.0f];
//    label.backgroundColor = [UIColor clearColor];
//    
//    [navHeaderImage addSubview:label];
//
//    //self.navigationItem.titleView = navHeaderImage;
//    
//    [self.navigationController.navigationBar addSubview:navHeaderImage];
    
    // FIXME just for ios 5 
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navheader.png"] forBarMetrics:UIBarMetricsDefault];
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    // timer
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:90 
//                                                  target:self 
//                                                selector:@selector(fetchUpdatedInfo) 
//                                                userInfo:nil 
//                                                 repeats:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView=nil;
    //[self.timer invalidate];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    // load remote data and init tableview
    //[self fakeFetchLoudList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *bgHeader = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)] autorelease];
    bgHeader.image = [UIImage imageNamed:@"tableheader.png"];
    return bgHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (UITableViewCell *)creatNormalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *loud = [self.louds objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                                      constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                          lineBreakMode:UILineBreakModeWordWrap].height;

    CellIdentifier = [NSString stringWithFormat:@"helpEntry:%.0f", contentHeight];
    
    LoudTableCell *cell = (LoudTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[LoudTableCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:CellIdentifier 
                                              height:contentHeight] autorelease];
        } 
    
    
    // avatar
    
    NSDictionary *user = [loud objectForKey:@"user"];
    [[UserManager sharedInstance] fetchUserRequestWithLink:user forBlock:^(NSDictionary *data){
        
        cell.nameLabel.text = [data objectForKey:@"name"];
        if (300 == [[data objectForKey:@"role"] intValue]){
            // administractor
            cell.nameLabel.textColor = [UIColor colorWithRed:245/255.0 green:161/255.0 blue:0/255.0 alpha:1.0];
        }else {
            cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        }
        
    }];
    
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        cell.avatarImage.image = [UIImage imageNamed:@"avatar.png"];
    }];
    
    // content
    cell.cellText.text = [loud objectForKey:@"content"];
    
    // location infomation
    cell.locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:loud];
    //[loud setObject:cell.distanceLabel.text forKey:@"distanceInfo"]; something worng
    
    if (nil == [loud objectForKey:@"createdTime"]){
        [loud setObject:[Utils dateFromISOStr:[loud objectForKey:@"created"]] forKey:@"createdTime"];
    }
    
    // date time
    cell.timeLabel.text = [Utils descriptionForTime:[loud objectForKey:@"createdTime"]];
    
    // comments 
    if ([[loud objectForKey:@"reply_num"] intValue] >= 0){
        cell.commentLabel.hidden = NO;
        cell.commentLabel.text = [NSString stringWithFormat:@"%d条评论", [[loud objectForKey:@"reply_num"] intValue]];
        
    } else {
        cell.commentLabel.hidden = YES;
    }
    
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

        CGSize theSize= [[loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                                   constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                       lineBreakMode:UILineBreakModeWordWrap];
        
        return theSize.height + NAMEFONTSIZE + TEXTFONTSIZE + SMALLFONTSIZE + 79;
    } else{
        
        return 40.0f;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.louds count]){
        
        DetailLoudViewController *dlVC = [[DetailLoudViewController alloc] initWithNibName:@"DetailLoudViewController" bundle:nil];
        dlVC.loud = [self.louds objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:dlVC animated:YES];
        [dlVC release];
    }
     
}

#pragma mark - RESTful request
- (void)fakeFetchLoudList
{
    if ([CLLocationManager locationServicesEnabled]){
        if (nil != [ProfileManager sharedInstance].profile){
            [[LocationController sharedInstance].locationManager startUpdatingLocation];
            [self performSelector:@selector(fetchLoudList) withObject:nil afterDelay:2.0];        
        }

    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    } 

}

- (void)fetchLoudList
{

    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    
    if (NO == [LocationController sharedInstance].allow){
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?q=position:%f,%f&qs=%@&st=%d&qn=%d", 
                                        HOST,
                                        LOUDSEARCH,
                                        curloc.latitude, 
                                        curloc.longitude, 
                                        [@"created desc" URLEncodedString],
                                         0, 6
                                       ]];
    
  
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    //[request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestListDone:)];
    [request setDidFailSelector:@selector(requestListWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)requestListDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        NSString *body = [request responseString];
        
        //NSLog(@"body: %@", body);
        // create the json parser 
        NSMutableDictionary * collection = [body JSONValue];
        
        
        self.curCollection = collection;
        self.louds = [collection objectForKey:@"louds"];
        self.etag = [[request responseHeaders] objectForKey:@"Etag"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
        [[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil ];
        
        
    } else if (304 == code){
        // do nothing
    } else if (400 == code) {
        
        [Utils warningNotification:@"参数错误"];
        
    } else if (401 == code){
        [Utils warningNotification:@"授权失败"];
    } else{
        
        [Utils warningNotification:@"服务器异常返回"];
        
    }
}

- (void)requestListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request loud list: %@", [error localizedDescription]);
    
}


- (void)fetchNextLoudList
{
    if (nil == self.louds || nil == [self.curCollection objectForKey:@"next"]){
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.curCollection objectForKey:@"next"]]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestNextListDone:)];
    [request setDidFailSelector:@selector(requestNextListWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
    
}

- (void)requestNextListDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        
        NSString *body = [request responseString];
        // create the json parser 
        NSMutableDictionary *collection = [body JSONValue];
        
        self.curCollection = collection;
        [self.louds addObjectsFromArray:[collection objectForKey:@"louds"]];
        
        // reload the tableview data
        [self.tableView reloadData];
        
    } else if (400 == code) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"服务器异常返回"];
    }
    
}

- (void)requestNextListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request next loud list: %@", [error localizedDescription]);
    
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
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

@end
