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
// custom
#import "NSString+URLEncoding.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "DetailLoudViewController.h"
#import "UserManager.h"
#import "CustomItems.h"


@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;
@synthesize timer=timer_;
@synthesize tableView=tableView_;

#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [etag_ release];
    [curCollection_ release];
    [timer_ release];
    [loudCates_ release];
    [payCates_ release];
    [tableView_ release];
    
    [super dealloc];
}

- (NSDictionary *)loudCates
{
    if (nil == loudCates_){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"LoudCate" ofType:@"plist"];
        loudCates_ = [[NSDictionary alloc] initWithContentsOfFile:myFile];
    }
    
    return loudCates_;
}

- (NSDictionary *)payCates
{
    if (nil == payCates_){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"payCate" ofType:@"plist"];
        payCates_ = [[NSDictionary alloc] initWithContentsOfFile:myFile];
        
    }
    
    return payCates_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
       
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    // custom navigation item
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"附近的求助"] autorelease];

    
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
    
    // filter the non show louds, clean
    if (self.louds != nil) {
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *loud, NSDictionary *bindings){
            
            int interval = [[Utils dateFromISOStr:[loud objectForKey:@"expired"]] timeIntervalSinceNow];
            
            return [[loud objectForKey:@"status"] intValue] == 200 && interval > 0;
            
        }];
        [self.louds filterUsingPredicate:p];
        [self.tableView reloadData];
    }
    
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
    
    // name 
    cell.nameLabel.text = [user objectForKey:@"name"];
    if (300 == [[user objectForKey:@"role"] intValue]){
        // administractor
        cell.nameLabel.textColor = [UIColor colorWithRed:245/255.0 green:161/255.0 blue:0/255.0 alpha:1.0];
    }else {
        cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }
    
    [cell retain]; // #{ for tableview may dealloc
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        
        if (nil != data){
            cell.avatarImage.image = [UIImage imageWithData: data];
        }
        
        [cell release]; // #} relase it
    }];
    
    // content
    cell.cellText.text = [loud objectForKey:@"content"];
    
    // location infomation
    cell.locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:loud];
    
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
    
    // loud categories and pay categories
    NSDictionary *loudcate = [self.loudCates objectForKey:[loud objectForKey:@"loudcate"]];
    NSDictionary *paycate = [self.payCates objectForKey:[loud objectForKey:@"paycate"]];
    
    if (nil != loudcate){
        cell.loudCateLabel.image = [UIImage imageNamed:[loudcate objectForKey:@"stripPic"]];
        cell.loudCateImage.image = [UIImage imageNamed:[loudcate objectForKey:@"colorPic"]];
    }
    
    if (nil != paycate){
        //NSLog(@"paycate %@ %@,%@", [paycate objectForKey:@"label"], [paycate objectForKey:@"logo"], [paycate objectForKey:@"showPic"]);
        cell.payCateImage.image = [UIImage imageNamed:[paycate objectForKey:@"showPic"]];
    }
    
    // pay categories description
    if ([NSNull null] == [loud objectForKey:@"paydesc"]){
        cell.payCateDescLabel.text = [paycate objectForKey:@"text"];
    } else{
        cell.payCateDescLabel.text = [NSString stringWithFormat:@"%@, %@",
                                      [paycate objectForKey:@"text"],
                                      [loud objectForKey:@"paydesc"]];
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
        
        return theSize.height + NAMEFONTSIZE + TEXTFONTSIZE + SMALLFONTSIZE + 79 - 10;
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
