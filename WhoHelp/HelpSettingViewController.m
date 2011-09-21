//
//  HelpSettingViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSettingViewController.h"
#import "ChangPassswordViewController.h"
#import "ChangNameViewController.h"
#import "ChangAvatarViewController.h"
#import "LoudManageViewController.h"
#import "DeleteAccountViewController.h"

@implementation HelpSettingViewController

- (NSMutableArray *)menu
{
    if (nil == menu_){
        menu_ = [[NSMutableArray alloc] init];
        
        NSMutableArray *tmp;
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"我的求助"];
        [menu_ addObject:tmp];
        [tmp release];
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"修改昵称"];
        [tmp addObject:@"修改头像"];
        [tmp addObject:@"修改密码"];
        [menu_ addObject:tmp];
        [tmp release];
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"退出登录"];
        [tmp addObject:@"注销帐号"];
        [menu_ addObject:tmp];
        [tmp release];
    }
    
    return menu_;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (0 == section){
        return 1;
    } else if (1 == section){
        return 3;
    } else if (2 == section){
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    NSString *menuString = [[self.menu objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]; 
    cell.textLabel.text = menuString;
    if (![menuString isEqual:@"退出登录"]){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
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
    
    if (0 == indexPath.section && 0 == indexPath.row){
        LoudManageViewController *loudVC = [[LoudManageViewController alloc] initWithNibName:@"LoudManageViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:loudVC animated:YES];
        [loudVC release];

    } else if(1 == indexPath.section && 0 == indexPath.row){
        ChangNameViewController *changNameVC = [[ChangNameViewController alloc] initWithNibName:@"ChangNameViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changNameVC animated:YES];
        [changNameVC release];
    } else if(1 == indexPath.section && 1 == indexPath.row){
        ChangAvatarViewController *changAvatarVC = [[ChangAvatarViewController alloc] initWithNibName:@"ChangAvatarViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changAvatarVC animated:YES];
        [changAvatarVC release];
    } else if (1 == indexPath.section && 2 == indexPath.row){
        ChangPassswordViewController *changPassVC = [[ChangPassswordViewController alloc] initWithNibName:@"ChangPassswordViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changPassVC animated:YES];
        [changPassVC release];

    } else if(2 == indexPath.section && 1 == indexPath.row){
        DeleteAccountViewController *deleteAccountVC = [[DeleteAccountViewController alloc] initWithNibName:@"DeleteAccountViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:deleteAccountVC animated:YES];
        [deleteAccountVC release];
    } else if(2 == indexPath.section && 0 == indexPath.row){
        // TODO   
    }
     
}

- (void)dealloc
{
    [menu_ release];
    [super dealloc];
}

@end
