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
#import "ProfileManager.h"
#import "LocationController.h"
// custom
#import "NSString+URLEncoding.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "DetailLoudViewController.h"
#import "CustomItems.h"
#import "HelpSendViewController.h"
#import "PreAuthViewController.h"


@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;
@synthesize timer=timer_;
@synthesize tableView=tableView_;
@synthesize lastUpdated;

#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [etag_ release];
    [curCollection_ release];
    [timer_ release];
    [tableView_ release];
    [lastUpdated release];
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"全部信息"] autorelease];

    
    // timer
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 
//                                                  target:self 
//                                                selector:@selector(fetchUpdatedInfo) 
//                                                userInfo:nil 
//                                                 repeats:YES];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]  
                                              initWithTitle:@"求助" 
                                              style:UIBarButtonSystemItemAdd 
                                              target:self 
                                              action:@selector(sendLoudAction:)] autorelease];
    
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
    
    if (self.louds != nil) {
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *loud, NSDictionary *bindings){
            
            return ![[loud objectForKey:@"status"] isEqualToString:@"del"];
            
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

    // load remote data and init tableview
//    [self egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
//    [_refreshHeaderView animationDidStart:(CAAnimation *)];
//    [self.tableView setContentOffset:CGPointMake(0, -65) animated:YES];
//    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];



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
//    if ([user]){
//        // administractor
//        cell.nameLabel.textColor = [UIColor colorWithRed:245/255.0 green:161/255.0 blue:0/255.0 alpha:1.0];
//    }else {
//        cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
//    }
//    

    [cell.avatarImage loadImage:[user objectForKey:@"avatar_link"]];
    
    // content
    cell.cellText.text = [loud objectForKey:@"content"];
    
    // location infomation
//    cell.locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:loud];
    if (![[loud objectForKey:@"address"] isEqual:@""]) {
        cell.locationDescLabel.text =  [loud objectForKey:@"address"];
    }
    
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
        
        return theSize.height + NAMEFONTSIZE + TEXTFONTSIZE + SMALLFONTSIZE + 39 - 10;
    } else{
        
        return 40.0f;
    }
}

#pragma mark - actions
-(void)sendLoudAction:(id)sender
{
    if (nil == [ProfileManager sharedInstance].profile) {
        PreAuthViewController *preVc = [[PreAuthViewController alloc] initWithNibName:@"PreAuthViewController" bundle:nil];
        [self.tabBarController presentModalViewController:preVc animated:YES];
        [preVc release];
    } else {
        HelpSendViewController *helpVc = [[HelpSendViewController alloc] initWithNibName:@"HelpSendViewController" bundle:nil];
        [self.tabBarController presentModalViewController:helpVc animated:YES];
        [helpVc release];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.louds count]){
        
        DetailLoudViewController *dlVC = [[DetailLoudViewController alloc] initWithNibName:@"DetailLoudViewController" bundle:nil];
        
        dlVC.loudLink = [[self.louds objectAtIndex:indexPath.row] objectForKey:@"link"];
        [self.navigationController pushViewController:dlVC animated:YES];
        [dlVC release];
    }
     
}

#pragma mark - RESTful request

- (void)fetchLoudList
{

    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?q=all:&st=%d&qn=%d", 
                                        HOST,
                                        LOUDSEARCH,
                                         0, 20
                                       ]];
    
  
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    //[request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestListDone:)];
    [request setDidFailSelector:@selector(requestListWentWrong:)];
//    [request signInHeader];
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
        
//        NSLog(@"collection: %@", collection);
        
        self.curCollection = collection;
        self.louds = [collection objectForKey:@"louds"];
        self.etag = [[request responseHeaders] objectForKey:@"Etag"];

        // reload the tableview data
        [self.tableView reloadData];
                
        [[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil ];
        self.lastUpdated = [[request responseHeaders] objectForKey:@"Last-Modified"];
        
        [self fadeInMsgWithText:@"已更新" rect:CGRectMake(0, 0, 60, 40)];
        
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


- (void)fetchNextLoudList
{
    if (nil == self.louds || nil == [self.curCollection objectForKey:@"next"]){
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.curCollection objectForKey:@"next"]]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestNextListDone:)];
    [request setDidFailSelector:@selector(requestNextListWentWrong:)];
//    [request signInHeader];
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

#pragma mark - get update info
- (void)fetchUpdatedInfo
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", 
                                       TESTHOST,
                                       ULOUDURI
                                       ]
                  ];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    if (nil != self.lastUpdated){
        [request addRequestHeader:@"If-Modified-Since" value:self.lastUpdated];
    }
    //[request setValidatesSecureCertificate:NO];
    [request setCompletionBlock:^{
        // Use when fetching text data
        if (200 == [request responseStatusCode]) {
            NSString *body = [request responseString];
            NSDictionary *info = [body JSONValue];
            
            int loudNum = [[info objectForKey:@"num"] intValue];
            if (loudNum > 0 ){
                [[[self.tabBarController.tabBar items] objectAtIndex:0] 
                 setBadgeValue:[NSString stringWithFormat:@"%d", loudNum]];
            } else{
                [[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil];
            }
            
        } else{
            NSLog(@"error: %@", @"非正常返回");
        }
        
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"network link error:%@", [error localizedDescription]);
    }];
    [request signInHeader];
    [request startAsynchronous];
    
}



#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchLoudList];

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
