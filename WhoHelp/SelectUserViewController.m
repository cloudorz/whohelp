//
//  SelectUserViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectUserViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "SBJson.h"
#import "Config.h"
#import "CustomItems.h"
#import "ProfileManager.h"
#import "Utils.h"
#import "UserManager.h"

@implementation SelectUserViewController

@synthesize tableView=tableView_;
@synthesize loudURN=loudURN_;
@synthesize users=users_;
@synthesize phvc=phvc_;


-(void)dealloc
{
    [tableView_ release];
    [loudURN_ release];
    [users_ release];
    [phvc_ release];
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

    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"谁帮了你?"] autorelease];
}

#pragma mark - actions
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchUserList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    return self.users.count;
}

#pragma mark - RESTful request

- (void)fetchUserList
{
    // get the loud id
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", HOST, USERLISTURI, self.loudURN]];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

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
        self.users = [body JSONValue];
        
        // reload the tableview data
        [self.tableView reloadData];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UserTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    
    cell.name.text = [user objectForKey:@"name"];
    
    [cell retain]; //{#
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        if (data != nil){
            cell.avatarImage.image = [UIImage imageWithData:data];  
        }
        [cell release]; //#}

    }];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *sectionView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 27)] autorelease];
    sectionView.image = [UIImage imageNamed:@"bar.png"];
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(12, 0, 100, 27)] autorelease];
    title.backgroundColor = [UIColor clearColor];
    title.opaque = NO;
    title.font = [UIFont boldSystemFontOfSize:14.0f];
    title.textColor = [UIColor whiteColor];
    title.text = @"热心人士"; 
    [sectionView addSubview:title];
    
    return sectionView;
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    self.phvc.toUser = [self.users objectAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
