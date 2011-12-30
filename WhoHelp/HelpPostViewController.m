//
//  HelpPostViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpPostViewController.h"
#import "HelpSendViewController.h"

@implementation HelpPostViewController

- (NSArray *)helpCategories
{
    if (helpCategories_ == nil){
        helpCategories_ = [[NSArray alloc] initWithObjects:
                           [NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"顺路拼车", @"text", @"pingche", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"征人跑腿", @"text", @"delivery", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"随便问问", @"text", @"virtual", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"修理任务", @"text", @"handyman", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"招贤纳士", @"text", @"jobs", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"打扫清理", @"text", @"cleaning", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"吃喝指导", @"text", @"foods", @"label", @"avatar.png", @"pic", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"游行指导", @"text", @"travel", @"label", @"avatar.png", @"pic", nil],
                            nil], 
                           nil]; 
    }
    return helpCategories_;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *helpCategory = [[self.helpCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = [helpCategory valueForKey:@"text"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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
                
    HelpSendViewController *sendHelpVC = [[HelpSendViewController alloc] initWithNibName:@"HelpSendViewController" bundle:nil];
    sendHelpVC.helpCategory = [[self.helpCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:sendHelpVC animated:YES];
    [sendHelpVC release];
    
}

-(void)dealloc
{
    [helpCategories_ release];
    [super dealloc];
}

@end
