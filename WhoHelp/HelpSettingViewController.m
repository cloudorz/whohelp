//
//  HelpSettingViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSettingViewController.h"
//#import "LawViewController.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "Utils.h"
#import "SBJson.h"
#import "ProfileManager.h"
#import "CustomItems.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "NSString+URLEncoding.h"
#import "DetailLoudViewController.h"
#import "MyProfileViewController.h"
#import "UserManager.h"

@implementation HelpSettingViewController

@synthesize tableView=tableView_;
@synthesize louds=louds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;
@synthesize toHelpIndicator=toHelpIndicator_;
@synthesize beHelpedIndicator=beHelpedIndicator_;
@synthesize starIndciator=starIndciator_;
@synthesize avatarImage=avatarImage_;
@synthesize nameLabel=nameLabel_;


#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [etag_ release];
    [curCollection_ release];
    [loudCates_ release];
    [payCates_ release];
    [tableView_ release];
    [tableView_ release];
    [toHelpIndicator_ release];
    [beHelpedIndicator_ release];
    [starIndciator_ release];
    [avatarImage_ release];
    [nameLabel_ release];
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"关于我"] autorelease];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _refreshHeaderView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // filter the non show louds, clean
    if (self.louds != nil) {
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *loud, NSDictionary *bindings){

            int status = [[loud objectForKey:@"status"] intValue];
            return status != 300 && status != -100;
            
        }];
        [self.louds filterUsingPredicate:p];
        [self.tableView reloadData];
    }
    
    // reinit the user info
    self.nameLabel.text = [ProfileManager sharedInstance].profile.name;
    self.avatarImage.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    NSDictionary *user = [NSDictionary dictionaryWithObjectsAndKeys:
                          [ProfileManager sharedInstance].profile.urn, @"id", 
                          [ProfileManager sharedInstance].profile.link, @"link",
                          nil];
    [[UserManager sharedInstance] fetchUserRequestWithLink:user forBlock:^(NSDictionary *data){
        self.toHelpIndicator.text = [[data objectForKey:@"to_help_num"] description];
        self.beHelpedIndicator.text = [[data objectForKey:@"be_helped_num"] description];
        self.starIndciator.text = [[data objectForKey:@"star_num"] description];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // init the list
    [self egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions
-(IBAction)profileAction:(id)sender
{
    MyProfileViewController *mpvc = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    [self.navigationController pushViewController:mpvc animated:YES];
    [mpvc release];
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
    
    return self.louds.count + 1;
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
    NSDictionary *paycate = [self.payCates objectForKey:[loud objectForKey:@"paycate"]];
    NSString *payDesc = nil;
    // pay categories description
    if ([NSNull null] == [loud objectForKey:@"paydesc"]){
        payDesc = [paycate objectForKey:@"text"];
    } else{
        payDesc = [NSString stringWithFormat:@"%@, %@",
                                      [paycate objectForKey:@"text"],
                                      [loud objectForKey:@"paydesc"]];
    }
    
    NSString *content = [NSString stringWithFormat:@"%@ 报酬: %@", [loud objectForKey:@"content"], payDesc];
    
    CGFloat contentHeight= [content sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                                      constrainedToSize:CGSizeMake(228, CGFLOAT_MAX) 
                                                          lineBreakMode:UILineBreakModeWordWrap].height;
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"myHelpEntry:%.0f", contentHeight];
    
    MyLoudTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[MyLoudTableCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:CellIdentifier 
                                              height:contentHeight] autorelease];
    }
    
    // content
    cell.contentLabel.text = content;
    
        // date time
    if (nil == [loud objectForKey:@"expiredTime"]){

        [loud setObject:[Utils dateFromISOStr:[loud objectForKey:@"expired"]] forKey:@"expiredTime"];
    }
    cell.timeLabel.text = [Utils pastDueTimeDesc:[loud objectForKey:@"expiredTime"]];
    
    // comments 
    if ([[loud objectForKey:@"reply_num"] intValue] >= 0){
        cell.commentLabel.hidden = NO;
        cell.commentLabel.text = [NSString stringWithFormat:@"%d条评论", [[loud objectForKey:@"reply_num"] intValue]];
        
    } else {
        cell.commentLabel.hidden = YES;
    }
    
    // loud categories and pay categories
    NSDictionary *loudcate = [self.loudCates objectForKey:[loud objectForKey:@"loudcate"]];
    
    if (nil != loudcate){
        cell.logoImage.image = [UIImage imageNamed:[loudcate objectForKey:@"logo"]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    if (indexPath.row < [self.louds count]){
        
        NSDictionary *loud = [self.louds objectAtIndex:indexPath.row];
        NSDictionary *paycate = [self.payCates objectForKey:[loud objectForKey:@"paycate"]];
       
        NSString *payDesc = nil;
        // pay categories description
        if ([NSNull null] == [loud objectForKey:@"paydesc"]){
            payDesc = [paycate objectForKey:@"text"];
        } else{
            payDesc = [NSString stringWithFormat:@"%@, %@",
                       [paycate objectForKey:@"text"],
                       [loud objectForKey:@"paydesc"]];
        }
        
        NSString *content = [NSString stringWithFormat:@"%@ 报酬: %@", [loud objectForKey:@"content"], payDesc];
        
        CGFloat contentHeight= [content sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                      constrainedToSize:CGSizeMake(228.0f, CGFLOAT_MAX) 
                                          lineBreakMode:UILineBreakModeWordWrap].height;
        
        return contentHeight + 65;
    } else{
        
        return 40.0f;
    }
}

- (void)fetchLoudList
{
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?q=author:%@&qs=%@&st=%d&qn=%d", 
                                       HOST,
                                       LOUDSEARCH,
                                       [ProfileManager sharedInstance].profile.userkey,
                                       [@"created desc" URLEncodedString],
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
    [self fetchLoudList];
    // some more actions here 
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
