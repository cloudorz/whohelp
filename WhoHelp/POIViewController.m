//
//  POIViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "POIViewController.h"
#import "CustomItems.h"

@interface POIViewController ()

@end

@implementation POIViewController
@synthesize myNavigationItem=_myNavigationItem;
@synthesize mapView=_mapView;
@synthesize tableView=_tableView;
@synthesize headerView=_headerView;
@synthesize searchBar=_searchBar;

-(void)dealloc
{
    [_myNavigationItem release];
    [_mapView release];
    [_tableView release];
    [_headerView release];
    [_searchBar release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.myNavigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                                initBackBarButtonItemWithTarget:self 
                                                action:@selector(backAction:)] autorelease];
    self.myNavigationItem.title = nil;
    self.tableView.tableHeaderView = self.headerView;
}

-(void)backAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    return 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
