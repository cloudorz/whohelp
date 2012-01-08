//
//  DetailLoudViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailLoudViewController.h"
#import "Config.h"
#import "ProfileManager.h"
#import "UserManager.h"
//#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "LocationController.h"
#import "CustomItems.h"

// lots
#import "ToHelpViewController.h"
#import "PrizeHelperViewController.h"
#import "ProfileViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "SBJson.h"

@implementation DetailLoudViewController

@synthesize loud=loud_;
@synthesize tableView=tableView_;
@synthesize avatar=avatar_;
@synthesize user=user_;
@synthesize toHelpNumIndicator=toHelpNumIndicator_;
@synthesize starNumIndicator=starNumIndicator_;
@synthesize helpNumIndicator=helpNumIndicator_;
@synthesize justLookIndicaotr=justLookIndicaotr_;
@synthesize otherUserView=otherUserView_;
@synthesize myView=myView_;
@synthesize avatarImage=avatarImage_;
@synthesize name=name_;
@synthesize replies=replies_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize moreCell=moreCell_;

- (void)dealloc
{
    [loud_ release];
    [tableView_ release];
    [loudCates_ release];
    [payCates_ release];
    [user_ release];
    [avatar_ release];
    [toHelpNumIndicator_ release];
    [starNumIndicator_ release];
    [helpNumIndicator_ release];
    [justLookIndicaotr_ release];
    [otherUserView_ release];
    [myView_ release];
    [avatarImage_ release];
    [name_ release];
    [etag_ release];
    [curCollection_ release];
    [replies_ release];
    [moreCell_ release];
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
    
    // common variables
    UIColor *bgColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
    UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
    
    // common variables - check is owner
    isOwner = [[ProfileManager sharedInstance].profile.urn isEqual:[self.user objectForKey:@"id"]];
    
    // navigation bar title
    self.navigationItem.titleView = [[NavTitleLabel alloc] 
                                     initWithTitle:[NSString stringWithFormat:@"%@的求助", isOwner ? @"我" :[self.user objectForKey:@"name"]]];
    
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    if (isOwner){
        self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                                   initDelBarButtonItemWithTarget:self action:@selector(delAction:)] autorelease];
    }
    
    // root view
    self.view.backgroundColor = [UIColor whiteColor];
    self.toHelpNumIndicator.text = [[self.user objectForKey:@"to_help_num"] description];
    self.starNumIndicator.text = [[self.user objectForKey:@"star_num"] description];
    
    self.name.text = [self.user objectForKey:@"name"];
    self.avatarImage.image = [UIImage imageWithData:self.avatar];
    if (isOwner){
        self.myView.hidden = NO;
        int justlook_num = [[self.loud objectForKey:@"reply_num"] intValue] - [[self.loud objectForKey:@"help_num"] intValue];

        [self.helpNumIndicator setTitle:[[self.loud objectForKey:@"help_num"] description] forState:UIControlStateNormal];
        [self.justLookIndicaotr setTitle:[NSString stringWithFormat:@"%d", justlook_num] forState:UIControlStateNormal];
    } else{
        self.otherUserView.hidden = NO;
    }
    
    // conetent  put below in table header view
    
    CGSize theSize= [[self.loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                               constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                   lineBreakMode:UILineBreakModeWordWrap];
    CGFloat contentHeight = theSize.height;
    CGFloat heightForAll = 67 + contentHeight + SMALLFONTSIZE;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, 320, heightForAll)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *contentText = [[[UILabel alloc] initWithFrame:CGRectMake(58,  10, TEXTWIDTH, contentHeight)] autorelease];
    contentText.textAlignment = UITextAlignmentLeft;
    contentText.lineBreakMode = UILineBreakModeWordWrap;
    contentText.numberOfLines = 0;
    contentText.font = [UIFont systemFontOfSize:TEXTFONTSIZE];
    contentText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    contentText.opaque = YES;
    contentText.backgroundColor = [UIColor clearColor];
    contentText.text = [self.loud objectForKey:@"content"];
    
    [tableHeaderView addSubview:contentText];
    
    // loud category color show
    UILabel *loudCateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 20+contentHeight, 320, 24)] autorelease];
    loudCateLabel.backgroundColor = [UIColor orangeColor]; 
    loudCateLabel.opaque = YES;
    
    UILabel *payCateDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 0, TEXTWIDTH, 24)] autorelease];
    payCateDescLabel.textAlignment = UITextAlignmentLeft;
    payCateDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    payCateDescLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
    payCateDescLabel.textColor = [UIColor whiteColor];
    payCateDescLabel.numberOfLines = 1;
    payCateDescLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingNone;
    payCateDescLabel.backgroundColor = [UIColor clearColor];
    [loudCateLabel addSubview:payCateDescLabel];
    
    // loud category and pay category image show
    UIImageView *loudCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(13, 16+contentHeight, 32, 32)] autorelease];
    loudCateImage.opaque = YES;
    loudCateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
    UIImageView *payCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 24, 24)] autorelease];
    payCateImage.backgroundColor = [UIColor clearColor];
    
    [loudCateImage addSubview:payCateImage];
    
    // loud categories and pay categories
    NSDictionary *loudcate = [self.loudCates objectForKey:[self.loud objectForKey:@"loudcate"]];
    NSDictionary *paycate = [self.payCates objectForKey:[self.loud objectForKey:@"paycate"]];
    
    if (nil != loudcate){
        NSArray *loudColor = [loudcate objectForKey:@"color"];
        //NSLog(@"loudcate %@ color: %@,%@,%@", [loudcate objectForKey:@"label"], [loudColor objectAtIndex:0], [loudColor objectAtIndex:1], [loudColor objectAtIndex:2]);
        loudCateLabel.backgroundColor = [UIColor colorWithRed:[[loudColor objectAtIndex:0] intValue]/255.0 
                                                        green:[[loudColor objectAtIndex:1] intValue]/255.0 
                                                         blue:[[loudColor objectAtIndex:2] intValue]/255.0 
                                                        alpha:1.0];
        loudCateImage.image = [UIImage imageNamed:[loudcate objectForKey:@"colorPic"]];
    }
    
    if (nil != paycate){
        //NSLog(@"paycate %@ %@,%@", [paycate objectForKey:@"label"], [paycate objectForKey:@"logo"], [paycate objectForKey:@"showPic"]);
        payCateImage.image = [UIImage imageNamed:[paycate objectForKey:@"showPic"]];
    }
    
    // pay categories description
    if ([NSNull null] == [self.loud objectForKey:@"paydesc"]){
        payCateDescLabel.text = [paycate objectForKey:@"text"];
    } else{
        payCateDescLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 [paycate objectForKey:@"text"],
                                 [self.loud objectForKey:@"paydesc"]];
    }
    
    [tableHeaderView addSubview:loudCateLabel];
    [tableHeaderView addSubview:loudCateImage];
    
    // location descrtion
    UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 55+contentHeight, 180, SMALLFONTSIZE+2)] autorelease];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
    locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
    locationImage.backgroundColor = [UIColor clearColor];
    [locationLabel addSubview:locationImage];
    
    UILabel *locationDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 150, SMALLFONTSIZE+2)] autorelease];
    locationDescLabel.textAlignment = UITextAlignmentLeft;
    locationDescLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    locationDescLabel.textColor = smallFontColor;
    locationDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    locationDescLabel.numberOfLines = 1;
    locationDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    locationDescLabel.backgroundColor = [UIColor clearColor];
    
    locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:self.loud];
    
    [locationLabel addSubview:locationDescLabel];
    
    [tableHeaderView addSubview:locationLabel];
    
    // comment infomation
    UILabel *commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(258, 55+contentHeight, 50, SMALLFONTSIZE+2)] autorelease]; // show
    commentLabel.opaque = YES;
    commentLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    commentLabel.textAlignment = UITextAlignmentRight;
    commentLabel.textColor = smallFontColor;
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
    //timeLabel.backgroundColor = bgGray;
    UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
    commentImage.frame = CGRectMake(0, 1, SMALLFONTSIZE, SMALLFONTSIZE);
    commentImage.backgroundColor = [UIColor clearColor];
    
    // comments 
    if ([[self.loud objectForKey:@"reply_num"] intValue] >= 0){
        commentLabel.hidden = NO;
        commentLabel.text = [NSString stringWithFormat:@"%d条评论", [[self.loud objectForKey:@"reply_num"] intValue]];
        
    } else {
        commentLabel.hidden = YES;
    }
    
    [commentLabel addSubview:commentImage];
    
    [tableHeaderView addSubview:commentLabel];
    
    
    UILabel *cbottomLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, heightForAll-1, 320, 1)] autorelease];
    cbottomLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:229/255.0 blue:226/255.0 alpha:1.0];
    cbottomLine.opaque = YES;
    
    [tableHeaderView addSubview:cbottomLine];
    
    // tableview
    self.tableView.backgroundColor = bgColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableHeaderView = tableHeaderView;
//    CGRect tableFrame = self.tableview.frame;
//    tableFrame.size.height -= 66;
//    tableFrame.origin.y += 66;
//    self.tableview.frame = tableFrame;
    
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

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions for button


-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)delAction:(id)sender
{
    NSLog(@"Pls. delete me");
}

-(IBAction)avatarButtonAction:(id)sender
{
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    pvc.user = self.user;
    pvc.avatar = self.avatar;
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
    
}

-(IBAction)helpDoneAction:(id)sender
{
    PrizeHelperViewController *pvc = [[PrizeHelperViewController alloc] initWithNibName:@"PrizeHelperViewController" bundle:nil];
    pvc.loud = self.loud;
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
}

-(IBAction)toHelpAction:(id)sender
{
    ToHelpViewController *tpv = [[ToHelpViewController alloc] initWithNibName:@"ToHelpViewController" bundle:nil];
    tpv.loud = self.loud;
    tpv.isHelp = YES;
    [self.navigationController pushViewController:tpv animated:YES];
}

-(IBAction)justLookAction:(id)sender
{
    ToHelpViewController *tpv = [[ToHelpViewController alloc] initWithNibName:@"ToHelpViewController" bundle:nil];
    tpv.loud = self.loud;
    tpv.isHelp = NO;
    [self.navigationController pushViewController:tpv animated:YES];
}

#pragma mark - grap the comments
- (void)fetchReplyList
{
    
    NSURL *url = [NSURL URLWithString:[self.loud objectForKey:@"replies_link"]];
    
    
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
        self.replies = [collection objectForKey:@"replies"];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.replies.count + 1;
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
    NSMutableDictionary *reply = [self.replies objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [[reply objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                                      constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                          lineBreakMode:UILineBreakModeWordWrap].height;
    
    CellIdentifier = [NSString stringWithFormat:@"replyEntry:%.0f", contentHeight];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:CellIdentifier 
                                              /*height:contentHeight*/] autorelease];
    } 
    
    
    // avatar
    
    NSDictionary *user = [reply objectForKey:@"user"];
    
    [cell retain]; // #{ for tableview may dealloc
    [[UserManager sharedInstance] fetchUserRequestWithLink:user forBlock:^(NSDictionary *data){
        
        if (nil != data){
//            cell.nameLabel.text = [data objectForKey:@"name"];
//            if (300 == [[data objectForKey:@"role"] intValue]){
//                // administractor
//                cell.nameLabel.textColor = [UIColor colorWithRed:245/255.0 green:161/255.0 blue:0/255.0 alpha:1.0];
//            }else {
//                cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
//            }
        }
        
        [cell release]; // #}
    }];
    
    [cell retain]; // #{ for tableview may dealloc
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        
//        if (nil != data){
//            cell.avatarImage.image = [UIImage imageWithData: data];
//        }
//        
        [cell release]; // #} relase it
    }];
    
    // content
    cell.textLabel.text = [NSString stringWithFormat:@"%@,(%@),", [reply objectForKey:@"content"], [reply objectForKey:@"is_help"]];
//    
//    // location infomation
//    cell.locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:loud];
//    
//    if (nil == [reply objectForKey:@"createdTime"]){
//        [reply setObject:[Utils dateFromISOStr:[loud objectForKey:@"created"]] forKey:@"createdTime"];
//    }
//    
//    // date time
//    cell.timeLabel.text = [Utils descriptionForTime:[loud objectForKey:@"createdTime"]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.replies count]) {
		return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
	}
	else {
		return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
	}
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchReplyList];
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

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

@end
