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

@implementation HelpListViewController

@synthesize louds=louds_;
@synthesize myLouds=myLouds_;
@synthesize curCollection=curCollection_;
@synthesize etag=etag_;
@synthesize userEtag=userEtag_;
@synthesize moreCell=moreCell_;
@synthesize tapUser=tapUser_;
//@synthesize tapLoud=tapLoud_;
@synthesize tapLoudLink=tapLoudLink_;
@synthesize tapIndexPath=tapIndexPath_;
@synthesize tmpList=tmpList_;
@synthesize lastUpdated=lastUpdated_;
@synthesize timer=timer_;

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
    
    // shake to my loud list
    _mylist = YES;
    
    // timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:90 
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
    self.tableView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
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
    [self fakeFetchLoudList];
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
    } else if (nil == [self.curCollection objectForKey:@"next"] || NO == _mylist){
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
    NSMutableDictionary *info = [self.photoCache objectForKey:[[loud objectForKey:@"user"] objectForKey:@"id"]];
    if (nil == info){
        cell.avatarImage.image = nil;
        NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                               cell, @"cell",
                               [loud objectForKey:@"user"], @"user",
                               nil];
        [self performSelectorInBackground:@selector(setPhotoAsync:) withObject:args];
    }else {
        cell.avatarImage.image = [UIImage imageWithData:[info objectForKey:@"photoData"]];
    }
    
    // name
    cell.nameLabel.text = [[loud objectForKey:@"user"] objectForKey:@"name"];
    
    if ([[[loud objectForKey:@"user"] objectForKey:@"is_admin"] boolValue]){
        cell.nameLabel.textColor = [UIColor colorWithRed:245/255.0 green:161/255.0 blue:0/255.0 alpha:1.0];
    }else {
        cell.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }
    
    // content
    cell.cellText.attributedText = [Utils colorContent:[loud objectForKey:@"content"]];
    
    // distnace
    cell.distanceLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:loud];
    //[loud setObject:cell.distanceLabel.text forKey:@"distanceInfo"]; something worng
    
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
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.louds count]){
        
        NSDictionary *loud = [self.louds objectAtIndex:indexPath.row];
        NSDictionary *user= [loud objectForKey:@"user"];
        
        if ([[ProfileManager sharedInstance].profile.phone isEqualToNumber:[user objectForKey:@"phone"]]){
            // del the user loud 
            UIActionSheet *delLoudSheet = [[UIActionSheet alloc] 
                                           initWithTitle:nil 
                                           delegate:self 
                                           cancelButtonTitle:@"取消" 
                                           destructiveButtonTitle:@"撤销求助" 
                                           otherButtonTitles:nil];
            
            delLoudSheet.tag = 2;
            [delLoudSheet showFromTabBar:self.tabBarController.tabBar];
            [delLoudSheet release];
            
            self.tapLoudLink = [loud objectForKey:@"link"];
            self.tapIndexPath = indexPath;

        } else{
            // contact the loud's owner.
            UIActionSheet *contactSheet = [[UIActionSheet alloc] 
                                           initWithTitle:[NSString stringWithFormat:@"联系:%@", [user objectForKey:@"name"]]
                                           delegate:self 
                                           cancelButtonTitle:@"取消" 
                                           destructiveButtonTitle:nil 
                                           otherButtonTitles:@"电话", @"短信", nil];
            
            contactSheet.tag = 1;
            [contactSheet showFromTabBar:self.tabBarController.tabBar];
            [contactSheet release];

            self.tapUser = user;
//            self.tapLoud = loud;
        }

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
            self.lastUpdated = [[request responseHeaders] objectForKey:@"Last-Modified"];
            
            _mylist = YES;
            // reload the tableview data
            [self.tableView reloadData];
            
            [[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil ];
            
            
        } else if (400 == [request responseStatusCode]) {
            
            [Utils warningNotification:@"参数错误"];
            
        } else if (304 == [request responseStatusCode]) {
            if (NO == _mylist){
                
                self.louds = self.tmpList;
                [self.tableView reloadData];
            }
            _mylist = YES;
            self.lastUpdated = [[request responseHeaders] objectForKey:@"Last-Modified"];
            //NSLog(@"the louds list not modified.");
        } else if (401 == [request responseStatusCode]){
            [Utils warningNotification:@"授权失败"];
        } else{
            
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

#pragma mark - set photo to cell
- (void)setPhotoAsync: (NSDictionary *)args
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    LoudTableCell *cell = [args objectForKey:@"cell"];
    NSDictionary *user = [args objectForKey:@"user"];
    cell.avatarImage.image = [UIImage imageWithData:[self photoFromUser:user]];
    
    [pool release];
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
        if (304 == [request responseStatusCode] || 200 == [request responseStatusCode]){
            [info setObject:[[request responseHeaders] objectForKey:@"Last-Modified"] forKey:@"last"];
            [info setObject:[NSDate date] forKey:@"expir"];
            if (200 == [request responseStatusCode]) {
                
                [info setObject:[request responseData] forKey:@"photoData"];
            } 
            
            [self.photoCache setObject:info forKey:[user objectForKey:@"id"]];
            
            return [info objectForKey:@"photoData"];
        }
   
    } else {
        //[Utils warningNotification:@"网络链接错误"]; 
    }

    return nil;
    
}

#pragma mark - actionsheetp delegate
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"click the button on action sheet");
//}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    
    if (1 == actionSheet.tag) {
//        if (2 == buttonIndex){
//            NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?ll=%@,%@", [self.tapLoud objectForKey:@"lat"], [self.tapLoud objectForKey:@"lon"]]];
//            NSLog(@"%@", callURL);
//            [[UIApplication sharedApplication] openURL:callURL];
//        } else {
        NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", buttonIndex == 0 ? @"tel" : @"sms", [self.tapUser objectForKey:@"phone"]]];
        
        UIDevice *device = [UIDevice currentDevice];
        
        if ([[device model] isEqualToString:@"iPhone"] ) {
            
            [[UIApplication sharedApplication] openURL:callURL];
        } else {
            
            [Utils wrongInfoString:@"你的设备不支持这项功能"];
        }
//        }
        
    } else if (2 == actionSheet.tag) {
        if (buttonIndex == actionSheet.destructiveButtonIndex){
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[Utils partURI:self.tapLoudLink queryString:[NSString stringWithFormat: @"ak=%@&tk=%@", APPKEY, [ProfileManager sharedInstance].profile.token]]];
            [request setRequestMethod:@"DELETE"];
            [request startSynchronous];
            
            NSError *error = [request error];
            if (!error) {
                if ([request responseStatusCode] == 200){
                    
                    if (_mylist == NO){
                        id anObject = [self.louds objectAtIndex:self.tapIndexPath.row];
                        [self.tmpList removeObject:anObject];
                    }
                    
                    [self.louds removeObjectAtIndex:self.tapIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.tapIndexPath] withRowAnimation:  UITableViewRowAnimationRight];

                } else {
                    [Utils warningNotification:@"非常规返回"];
                }
                
            }else{
                [Utils warningNotification:@"网络链接错误"];
            }

        }  
        
    }
    
}

#pragma mark - shake one
-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - get the three 
- (void)fetch3Louds
{
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat: @"%@?ak=%@&tk=%@&q=author:%@&qs=created desc&st=0&qn=3", SURI, APPKEY, [ProfileManager sharedInstance].profile.token, [ProfileManager sharedInstance].profile.phone] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
            
            self.userEtag = [[request responseHeaders] objectForKey:@"Etag"];
            self.myLouds = [result objectForKey:@"louds"];
            
        } else if (304 == [request responseStatusCode]){
            // done some thing
        } else if (400 == [request responseStatusCode]) {
            [Utils warningNotification:@"参数错误"];
        }else {
            [Utils warningNotification:@"非常规返回"];
        }
        
    }else{
        [Utils warningNotification:@"请求服务错误"];
    }

}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {

        if (_mylist){
            
            [self fetch3Louds];
            
            self.tmpList = self.louds;
            self.louds = self.myLouds;

            _mylist = NO;
            
        } else{
            
            self.louds = self.tmpList;
            _mylist = YES;
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - get update info
- (void)fetchUpdatedInfo
{
    if ([ProfileManager sharedInstance].profile.isLogin == NO || [LocationController sharedInstance].allow == NO){
        return;
    }
    
    // make json data for post
    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?ak=%@&tk=%@&lat=%f&lon=%f", UPDATEURI, APPKEY, [ProfileManager sharedInstance].profile.token, curloc.latitude, curloc.longitude]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.lastUpdated){
        [request addRequestHeader:@"If-Modified-Since" value:self.lastUpdated];
    }
    [request startSynchronous];
    
    
    NSError *error = [request error];
    if (!error){
        
        if (200 == [request responseStatusCode]) {
            NSData *responseData = [request responseData];
            // create the json parser 
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSDictionary *info = [jsonParser objectWithData:responseData];
            [jsonParser release];
            
            NSInteger num = [[info objectForKey:@"count"] intValue];
            if (num > 0 ){
                [[[self.tabBarController.tabBar items] objectAtIndex:0] 
                 setBadgeValue:[NSString stringWithFormat:@"%d", num]];
            } else{
                [[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil];
            }
     
        } else if (304 == [request responseStatusCode]){
            
            // do nothing
        } else if (401 == [request responseStatusCode]){
            NSLog(@"error: %@", @"无权操作");
        }else{
            NSLog(@"error: %@", @"非正常返回");
        }
        
    } else {
        [Utils warningNotification:@"网络链接错误"];
    }
    
}

#pragma mark - dealloc 
- (void)dealloc
{
    [louds_ release];
    [myLouds_ release];
    [tmpList_ release];
    [_refreshHeaderView release];
    [etag_ release];
    [userEtag_ release];
    [photoCache_ release];
    [curCollection_ release];
    [moreCell_ release];
    [tapUser_ release];
//    [tapLoud_ release];
    [tapLoudLink_ release];
    [tapIndexPath_ release];
    [lastUpdated_ release];
    [timer_ release];
    AudioServicesDisposeSystemSoundID(soudObject_);
    CFRelease(soundFileURLRef);
    [super dealloc];
}

@end
