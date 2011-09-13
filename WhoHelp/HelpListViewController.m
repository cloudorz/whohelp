//
//  HelpListViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpListViewController.h"
#import "WhoHelpAppDelegate.h"
#import "Profile.h"
#import "Loud.h"
#import "HelpDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@interface HelpListViewController (Private)
- (void)fetchLoudList;
- (void)addLouds;
- (void)deleteLouds;
- (void)syncLoudList;
- (NSManagedObject *)getLoudByLid:(NSNumber *)lid;
- (NSData *)fetchImage: (NSString *)partURI;
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)errorNotification:(NSString *)message;
- (void)warningNotification:(NSString *)message;
@end

#warning  TODO distance compute
#warning  TDOD position compute

@implementation HelpListViewController

@synthesize profiles=profiles_;
@synthesize newLouds=newLouds_;
@synthesize discardLouds=discardLouds_;
@synthesize louds=louds_;

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
  
    return managedObjectContext_;
}

- (void)updateLouds
{
    
    // This must be the request for our results controller. We don't have one yet
    // so we need to build it.
    
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Loud"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"captured == YES"];
    //[request setPredicate:predicate];

    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    if (mutableFetchResults == nil) {
        // Handle the error.
        NSLog(@"update the louds error: %@, %@", error, [error userInfo]);
    } else {
        self.louds = mutableFetchResults;
        [self.tableView reloadData];
    }
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
    
    // Get the data
    [self updateLouds];
    
 	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    return [self.louds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Loud *loud = [self.louds objectAtIndex:indexPath.row];
    cell.textLabel.text = loud.content;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     HelpDetailViewController *detailViewController = [[HelpDetailViewController alloc] initWithNibName:@"HelpDetailViewController" bundle:nil];
     // ...
    detailViewController.loud = [self.louds objectAtIndex:indexPath.row];
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     
}

#pragma mark - RESTful request
- (void)fetchLoudList
{
    NSLog(@"%@", @"fetching louds....");
    NSURL *url = [NSURL URLWithString:@"http://rest.whohelp.me/l/list?tk=q1w21&ak=12345678"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"processing louds...");
    //NSString *responseString = [request responseString];
    NSData *responseData = [request responseData];
    
    // create the json parser 
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    id result = [jsonParser objectWithData:responseData];
    [jsonParser release];
    
    if (error == nil){
        // set the newLouds 
 
        if ([request responseStatusCode] != 200){
            // Maybe a system error here FIXME
            NSLog(@"remote error: %@, %@", [request responseStatusCode], [request responseStatusMessage]);
            [self warningNotification:@"非正常返回."];
        } else{
            if ([result isKindOfClass:[NSMutableDictionary class]] &&
                [result objectForKey:@"status"] == @"fail"){
                NSLog(@"%@", @"The operation failed.");
                [self warningNotification:@"操作失败."];
                
            } else {
                self.newLouds = result;
                [self addLouds]; // save data to database
                [self updateLouds]; // update the MO data
            }
        }

        
    } else {
        // error handle TODO
        NSLog(@"louds json parser error: %@, %@", error, [error userInfo]);
        [self warningNotification:@"未知错误."];
        abort();
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // notify the user
    [self warningNotification:@"网络服务请求失败."];
    NSLog(@"error: %@, %@", error, [error userInfo]);
}

- (void)syncLoudList
{
#warning TODO instead of the fetch method.
    // TODO instead of the fetch method.
}

#pragma mark - handling errors
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message
{
    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [Notpermitted show];
    [Notpermitted release];
}

- (void)warningNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"warning" forMessage:message];
}

- (void)errorNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"错误" forMessage:message];  
}

#pragma mark - CRUD Loud and Profile

- (void)addLouds
{
    if (self.newLouds == nil){
        return;
    }
    
    NSLog(@"%@", @"update the louds list...");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    //[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN_POSIX"] autorelease]];
    
    for (int i=0, count=[self.newLouds count]; i < count; i++) {

        
        NSMutableDictionary *newLoud = [self.newLouds objectAtIndex:i];
        if ([self getLoudByLid:[newLoud valueForKey:@"id"]] == nil){
            Loud *loud = (Loud *)[NSEntityDescription insertNewObjectForEntityForName:@"Loud" inManagedObjectContext:self.managedObjectContext];
            loud.content = [newLoud valueForKey:@"content"];
            loud.lid = [newLoud valueForKey:@"id"];
            loud.grade = [newLoud valueForKey:@"grade"];
            loud.lat = [newLoud valueForKey:@"lat"];
            loud.lon = [newLoud valueForKey:@"lon"];
             
            NSTimeInterval plus8 = 8*60*60;
            loud.created = [[dateFormatter dateFromString:[newLoud objectForKey:@"created"]] dateByAddingTimeInterval:plus8];
            
            NSMutableDictionary *loudUser = [newLoud valueForKey:@"user"];
            loud.userName = [loudUser valueForKey:@"name"];
            loud.userAvatar = nil;//[loud_user objectForKey:@"avatar"]; // TODO get the image
            loud.userPhone = [loudUser valueForKey:@"phone"];
            

        }
        
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error. 
        [self warningNotification:@"数据存储失败."];
        NSLog(@"save data error: %@, %@", error, [error userInfo]);
    }
    
    [dateFormatter release];
}


- (void) deleteLouds
{
    
    if (self.discardLouds == nil){
        return;
    }
    
    for (int i=0, count=[self.discardLouds count]; i < count; i++) {
        NSManagedObject *loudToDelete = [self getLoudByLid:[self.discardLouds objectAtIndex:i]];
        [self.managedObjectContext deleteObject:loudToDelete];
    }
    // Commit the change.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error.
        [self warningNotification:@"数据存储失败."];
        NSLog(@"save data error: %@, %@", error, [error userInfo]);
    }    
   
}

- (NSManagedObject *)getLoudByLid:(NSNumber *)lid
{
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Loud"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lid == %@", lid]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];

    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            return [mutableFetchResults objectAtIndex:0];
        }

    } else {
        // Handle the error FIXME
        NSLog(@"get by lid error: %@, %@", error, [error userInfo]);
    }

    return nil;
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchLoudList];
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
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}


#pragma mark - dealloc 
- (void)dealloc
{
    [profiles_ release];
    [louds_ release];
    [managedObjectContext_ release];
    [_refreshHeaderView release];
    [super dealloc];
}

@end
