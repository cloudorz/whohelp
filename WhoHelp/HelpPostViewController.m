//
//  HelpPostViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpPostViewController.h"
#import "HelpSendViewController.h"
#import "CustomItems.h"

@implementation HelpPostViewController

@synthesize tableView=tableView_;

-(void)dealloc
{
    [helpCategories_ release];
    [tableView_ release];
    [super dealloc];
}


- (NSArray *)helpCategories
{
    if (helpCategories_ == nil){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"LoudCate" ofType:@"plist"];
        NSDictionary *loudCates = [NSDictionary dictionaryWithContentsOfFile:myFile];
        NSArray *sortedArray = [[loudCates allValues] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2){
            int dnum1 = [[d1 objectForKey:@"no"] intValue];
            int dnum2 = [[d2 objectForKey:@"no"] intValue];
            return dnum1 > dnum2;
        }];
        
        helpCategories_ = [[NSArray alloc] initWithObjects: sortedArray, nil]; 
        
    }
    
    return helpCategories_;
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
    
    // custom navigation item
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"求助"] autorelease];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return [self.helpCategories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[self.helpCategories objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"loudCateCell";
    
    LoudCateTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[LoudCateTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *helpCategory = [[self.helpCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.logo.image = [UIImage imageNamed:[helpCategory objectForKey:@"logo"]];
    cell.title.text = [helpCategory objectForKey:@"text"];
    cell.subtitle.text = [helpCategory objectForKey:@"desc"];
    cell.stickPic.image = [UIImage imageNamed:[helpCategory objectForKey:@"stickPic"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];            
    
    HelpSendViewController *sendHelpVC = [[HelpSendViewController alloc] initWithNibName:@"HelpSendViewController" bundle:nil];
    sendHelpVC.helpCategory = [[self.helpCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:sendHelpVC animated:YES];
    [sendHelpVC release];
    
}

@end
