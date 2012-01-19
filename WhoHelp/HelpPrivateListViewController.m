//
//  HelpPrivateListViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpPrivateListViewController.h"
#import "CustomItems.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "UserManager.h"
#import "SBJson.h"
#import "Utils.h"
#import "Config.h"
#import "NSString+URLEncoding.h"
#import "DetailLoudViewController.h"

@implementation HelpPrivateListViewController

@synthesize messages=messages_;
@synthesize curCollection=curCollection_;
@synthesize lastUpdated=lastUpdated_;
@synthesize tableView=tableView_;
@synthesize timer=timer_;

#pragma mark - dealloc 
- (void)dealloc
{
    [messages_ release];
    [curCollection_ release];
    [tableView_ release];
    [timer_ release];
    [lastUpdated_ release];
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"我的消息"] autorelease];
    
    // timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 
                                                  target:self 
                                                selector:@selector(fetchUpdatedInfo) 
                                                userInfo:nil 
                                                 repeats:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshHeaderView=nil;
    [self.timer invalidate];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // init the list
    [self egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
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
    return self.messages.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    
    static NSString *CellIdentifier = @"messageCateCell";
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                            reuseIdentifier:CellIdentifier] autorelease];
    } 
    
    
    NSMutableDictionary *message = [self.messages objectAtIndex:indexPath.row];
    
    // avatar
    
    NSDictionary *user = [message objectForKey:@"user"];
    
    [cell retain]; // #{ for tableview may dealloc
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        
        if (nil != data){
            cell.avatarImage.image = [UIImage imageWithData: data];
        }
        
        [cell release]; // #} relase it
    }];
    
    // content
    if ([[message objectForKey:@"label"] isEqualToString:@"help"]) {
        cell.contentLabel.text = [NSString stringWithFormat:@"%@的求助有人提供帮助", [user objectForKey:@"name"]];
    } else{
        cell.contentLabel.text = [NSString stringWithFormat:@"%@的求助有了新的回复", [user objectForKey:@"name"]]; 
    }
    
    
    if (nil == [message objectForKey:@"createdTime"]){
        [message setObject:[Utils dateFromISOStr:[message objectForKey:@"created"]] forKey:@"createdTime"];
    }
    
    // date time
    cell.timeLabel.text = [Utils descriptionForTime:[message objectForKey:@"createdTime"]];
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self fetchLoud:[[self.messages objectAtIndex:indexPath.row] objectForKey:@"loud_link"]];
     
}

- (void)fetchMsgList
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, MSGURI]];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.lastUpdated){
        [request addRequestHeader:@"If-Modified-Since" value:self.lastUpdated];
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
        
        NSMutableArray *tmpArray = [collection objectForKey:@"messages"];
        if (self.messages != nil) {
            [tmpArray addObjectsFromArray:self.messages];
        }
        self.messages = tmpArray;
        
        self.lastUpdated = [[request responseHeaders] objectForKey:@"Last-Modified"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
        [[[self.tabBarController.tabBar items] objectAtIndex:1] setBadgeValue:nil ];
        
        [self fadeInMsgWithText:@"已更新" rect:CGRectMake(0, 0, 60, 40)];
        
    } else{
        
        [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
        
    }
}

- (void)requestListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request loud list: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

- (void)fetchLoud:(NSString *)urlString
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    //[request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestLoudDone:)];
    [request setDidFailSelector:@selector(requestLoudWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)requestLoudDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        NSString *body = [request responseString];
        
        //NSLog(@"body: %@", body);
        // create the json parser 
        NSMutableDictionary * loud = [body JSONValue];
        DetailLoudViewController *detailViewController = [[DetailLoudViewController alloc] initWithNibName:@"DetailLoudViewController" bundle:nil];
        detailViewController.loud = loud;

        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
        
    } else{        

        [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
        
    }
}

- (void)requestLoudWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request loud list: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

#pragma mark - get update info
- (void)fetchUpdatedInfo
{

    // make json data for post
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, UMSGURI]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.lastUpdated){
        [request addRequestHeader:@"If-Modified-Since" value:self.lastUpdated];
    }
    //[request setValidatesSecureCertificate:NO];
    [request signInHeader];
    [request startSynchronous];
    
    
    NSError *error = [request error];
    if (!error){
        
        if (200 == [request responseStatusCode]) {
            NSString *body = [request responseString];
            NSDictionary *info = [body JSONValue];
            
                       
            int messageNum = [[info objectForKey:@"num"] intValue];
            if (messageNum > 0 ){
                [[[self.tabBarController.tabBar items] objectAtIndex:1] 
                 setBadgeValue:[NSString stringWithFormat:@"%d", messageNum]];
            } else{
                [[[self.tabBarController.tabBar items] objectAtIndex:1] setBadgeValue:nil];
            }

            
        } else{
            NSLog(@"error: %@", @"非正常返回");
        }
        
    } else {
        
        NSLog(@"network link error:%@", [error localizedDescription]);
    }
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchMsgList];
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
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

@end
