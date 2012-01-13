//
//  HelpPrizeViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpPrizeViewController.h"
#import "UserManager.h"
#import "Config.h"
#import "Utils.h"
#import "ProfileManager.h"
#import "CustomItems.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "NSString+URLEncoding.h"
#import "SBJson.h"
#import "ProfileViewController.h"

@implementation HelpPrizeViewController

@synthesize tableView=tableView_;
@synthesize etag=etag_;
@synthesize prizes=prizes_;
@synthesize curCollection=curCollection_;
@synthesize moreCell=moreCell_;
@synthesize helpotherIndicator=helpotherIndicator_;
@synthesize goodjosIndicator=goodjosIndicator_;
@synthesize sectionView=sectionView_;

#pragma mark - dealloc 
- (void)dealloc
{
    
    [tableView_ release];
    [etag_ release];
    [prizes_ release];
    [curCollection_ release];
    [moreCell_ release];
    [goodjosIndicator_ release];
    [helpotherIndicator_ release];
    [sectionView_ release];
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"感谢信"] autorelease];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshHeaderView=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return self.prizes.count + 1;
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
    NSMutableDictionary *prize = [self.prizes objectAtIndex:indexPath.row];
    NSDictionary *user = [prize objectForKey:@"provider"];
    NSString *lenContent = [NSString stringWithFormat:@"%@: %@", [user objectForKey:@"name"], [prize objectForKey:@"content"]];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                  constrainedToSize:CGSizeMake(228.0f, CGFLOAT_MAX) 
                                      lineBreakMode:UILineBreakModeWordWrap].height;
    
    CellIdentifier = [NSString stringWithFormat:@"prizeEntry:%.0f", contentHeight];
    
    PrizeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[PrizeTableCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:CellIdentifier 
                                               height:contentHeight] autorelease];
    } 
    
    
    // avatar
    [cell retain]; // #{ for tableview may dealloc
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        
        if (nil != data){
            cell.avatarImage.image = [UIImage imageWithData: data];
        }
        
        [cell release]; // #} relase it
    }];
    
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(avatarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // content
    cell.contentLabel.text = lenContent;
    
    // show phone logo
    if (1 == [[prize objectForKey:@"has_star"] intValue]){
        cell.starLogo.hidden = NO;
    } else{
        cell.starLogo.hidden = YES;
    }
    
    // date time
    if (nil == [prize objectForKey:@"createdTime"]){
        [prize setObject:[Utils dateFromISOStr:[prize objectForKey:@"created"]] forKey:@"createdTime"];
    }
    cell.timeLabel.text = [Utils descriptionForTime:[prize objectForKey:@"createdTime"]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.prizes count]) {
		return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else {
		return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    if (indexPath.row < [self.prizes count]){
        
        NSDictionary *prize = [self.prizes objectAtIndex:indexPath.row];
        NSDictionary *user = [prize objectForKey:@"user"];
        NSString *lenContent = [NSString stringWithFormat:@"%@: %@", [user objectForKey:@"name"], [prize objectForKey:@"content"]];
        
        CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                      constrainedToSize:CGSizeMake(228.0f, CGFLOAT_MAX) 
                                          lineBreakMode:UILineBreakModeWordWrap].height;
        
        return contentHeight + 55;
    } else{
        
        return 40.0f;
    }
}

- (void)loadNextReplyList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.
    
    [self fetchNextPrizeList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (nil != self.curCollection && 
        indexPath.row == [self.prizes count] && 
        nil != [self.curCollection objectForKey:@"next"]) 
    {
        
        [self performSelector:@selector(loadNextReplyList) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - actions
-(void)avatarButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    pvc.user = [[self.prizes objectAtIndex:button.tag] objectForKey:@"provider"];;
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
    
}

#pragma mark - grap the comments
- (void)fetchPrizeList
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?qs=%@&st=%d&qn=%d", 
                                       HOST,
                                       PRIZEURI,
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
        // set tile nums
        self.goodjosIndicator.text = [[collection objectForKey:@"stars"] description];
        self.helpotherIndicator.text = [[collection objectForKey:@"total"] description];
        
        self.prizes = [collection objectForKey:@"prizes"];
        self.etag = [[request responseHeaders] objectForKey:@"Etag"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
        //[[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil ];
        
        
    } else if (304 == code){
        // do nothing
    } else if (400 == code) {
        
        [Utils warningNotification:@"参数错误"];
        
    } else if (401 == code){
        [Utils warningNotification:@"需授权认证"];
    } else{
        
        [Utils warningNotification:@"服务器异常返回"];
        
    }
}

- (void)requestListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request replies list: %@", [error localizedDescription]);
    
}

- (void)fetchNextPrizeList
{
    if (nil == self.prizes || nil == [self.curCollection objectForKey:@"next"]){
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
        [self.prizes addObjectsFromArray:[collection objectForKey:@"prizes"]];
        
        // reload the tableview data
        [self.tableView reloadData];
        
    } else if (400 == code) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"服务器异常返回"];
    }
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchPrizeList];
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
