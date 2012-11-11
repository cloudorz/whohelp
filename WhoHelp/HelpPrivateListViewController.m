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
#import "SBJson.h"
#import "Utils.h"
#import "NSString+URLEncoding.h"
#import "DetailLoudViewController.h"
#import "DoubanAuthViewController.h"
#import "ProfileManager.h"

@interface HelpPrivateListViewController ()

-(void)loadMsgList;
-(BOOL)checkLogin;

@end

@implementation HelpPrivateListViewController

@synthesize messages=_messages;
@synthesize curCollection=_curCollection;
@synthesize lastUpdated=_lastUpdated;
@synthesize tableView=_tableView;
@synthesize moreCell=_moreCell;
@synthesize etag=_etag;


#pragma mark - dealloc 
- (void)dealloc
{
    [_tableView release];
    [_curCollection release];
    [_lastUpdated release];
    [_messages release];
    [_etag release];
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
    
    _loadloud = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshHeaderView=nil;
//    [self.timer invalidate];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(selectOtherTabAction:) 
                                                 name:@"cancelLogin" 
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"cancelLogin" 
                                                  object:nil];
}

- (void)selectOtherTabAction:(id)sender
{
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // init the list
    
    if ([self checkLogin]) {
        if (self.curCollection == nil) {
            [self loadMsgList];
        }
    }

}


-(void)loadMsgList
{
    [UIView animateWithDuration:0.7f animations:^{
        
        self.tableView.contentOffset = CGPointMake(0, -65);
        
    } completion:^(BOOL finished) {
        
         [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
        
    }];
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
    NSMutableDictionary *msg = [self.messages objectAtIndex:indexPath.row];

    NSString *lenContent = [msg objectForKey:@"content"];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                  constrainedToSize:CGSizeMake(272.0f, CGFLOAT_MAX) 
                                      lineBreakMode:UILineBreakModeWordWrap].height;
    
    CellIdentifier = [NSString stringWithFormat:@"msgEntry:%.0f", contentHeight];
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier 
                                               height:contentHeight] autorelease];
    } 
    
    
    // content
    cell.contentLabel.text = lenContent;
    
    
    if (nil == [msg objectForKey:@"createdTime"]){
        [msg setObject:[Utils dateFromISOStr:[msg objectForKey:@"created"]] forKey:@"createdTime"];
    }
    
    // date time
    cell.timeLabel.text = [Utils descriptionForTime:[msg objectForKey:@"createdTime"]];
    
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.messages count]) {
		return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else {
		return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    if (indexPath.row < [self.messages count]){
        
        NSDictionary *reply = [self.messages objectAtIndex:indexPath.row];
        NSDictionary *user = [reply objectForKey:@"user"];
        NSString *lenContent = [NSString stringWithFormat:@"%@: %@", [user objectForKey:@"name"], [reply objectForKey:@"content"]];
        
        CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                      constrainedToSize:CGSizeMake(272.0f, CGFLOAT_MAX) 
                                          lineBreakMode:UILineBreakModeCharacterWrap].height;
        
        return contentHeight + 40;
    } else{
        
        return 40.0f;
    }
}

- (void)loadNextReplyList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.
    
    [self fetchNextMsgList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (nil != self.curCollection && 
        indexPath.row == [self.messages count] && 
        nil != [self.curCollection objectForKey:@"next"]) 
    {
        
        [self performSelector:@selector(loadNextReplyList) withObject:nil afterDelay:0.2];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *msg = [self.messages objectAtIndex:indexPath.row];
    if (!_loadloud && 
        indexPath.row < [self.messages count] && 
        [[msg objectForKey:@"category"] isEqualToString:@"reply"]){

        DetailLoudViewController *detailViewController = [[DetailLoudViewController alloc] initWithNibName:@"DetailLoudViewController" bundle:nil];
        detailViewController.loudLink = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"obj_link"];

        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
     
}

- (void)fetchMsgList
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?st=%d&qn=%d", HOST, MSGURI, 0, 20]];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    if (nil != self.lastUpdated){
//        [request addRequestHeader:@"If-Modified-Since" value:self.lastUpdated];
//    }
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
        
        // create the json parser 
        NSMutableDictionary * collection = [body JSONValue];
        self.curCollection = collection;
        
        self.messages = [collection objectForKey:@"messages"];
         self.etag = [[request responseHeaders] objectForKey:@"Etag"];
//        self.lastUpdated = [[request responseHeaders] objectForKey:@"Last-Modified"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
//        [[[self.tabBarController.tabBar items] objectAtIndex:1] setBadgeValue:nil ];
        
    } else if (304 == code){
        // do nothing
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

- (void)fetchNextMsgList
{
    if (nil == self.messages || nil == [self.curCollection objectForKey:@"next"]){
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
        [self.messages addObjectsFromArray:[collection objectForKey:@"replies"]];
        
        // reload the tableview data
        [self.tableView reloadData];
        
    } else{
        
        [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
    }
    
}

- (void)requestNextListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request next loud list: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
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

-(BOOL)checkLogin
{
    if (nil == [ProfileManager sharedInstance].profile){
        
        DoubanAuthViewController *loginVC = [[DoubanAuthViewController alloc] initWithNibName:@"DoubanAuthViewController" 
                                                                                 bundle:nil];
        [self presentModalViewController:loginVC animated:YES];
        [loginVC release];
        
        return NO;
    }
    
    return YES;
}

@end
