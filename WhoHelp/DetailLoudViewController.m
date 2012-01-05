//
//  DetailLoudViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailLoudViewController.h"
#import "Config.h"

@implementation DetailLoudViewController

@synthesize loud=loud_;
@synthesize commentTable=commentTable_;

- (void)dealloc
{
    [loud_ release];
    [commentTable_ release];
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
    // Do any additional setup after loading the view from its nib.
    // common variables
    UIColor *bgColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
    
    // root view
    self.view.backgroundColor = [UIColor whiteColor];
    
    // tableview
    self.commentTable.backgroundColor = bgColor;
    self.commentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    CGRect tableFrame = self.commentTable.frame;
    self.commentTable.frame = tableFrame;
    tableFrame.origin.y = 100;
    
    // user header
    UILabel *userHeader = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 61)] autorelease];
    userHeader.backgroundColor = bgColor;
    
    // user header - avatar
    UIImageView *userAvatar = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 35, 35)] autorelease];
    userAvatar.opaque = YES;
    userAvatar.backgroundColor = [UIColor clearColor];
    // set image
    [userHeader addSubview:userAvatar];
    
    // user header - name
    UILabel *userName = [[[UILabel alloc] initWithFrame:CGRectMake(58, 14, 100, 14)] autorelease];
    userName.opaque = YES;
    userName.textColor = [UIColor blackColor];
    userName.backgroundColor = [UIColor clearColor];
    userName.font = [UIFont boldSystemFontOfSize: NAMEFONTSIZE];
    // set nameLabel text
    [userHeader addSubview:userName];
    
    // user header - meta infomation
    UILabel *userMeta = [[UILabel alloc] initWithFrame:CGRectMake(58, 24+NAMEFONTSIZE, 100, 12)];
    userMeta.opaque = YES;
    userMeta.textColor = [UIColor colorWithRed:166/255.0 green:157/255.0 blue:152/255.0 alpha:1.0];
    userMeta.backgroundColor = [UIColor clearColor];
    userMeta.font = [UIFont systemFontOfSize: 10.0f];
    // set meta info
    [userHeader addSubview:userMeta];
    

    UIImageView *offerHelpImage = [[[UIImageView alloc] initWithFrame:CGRectMake(204, 13, 28, 36)] autorelease];
    offerHelpImage.opaque = YES;
    offerHelpImage.backgroundColor = [UIColor clearColor];
    // set image TODO
    // set num indicator TODO
    [userHeader addSubview:offerHelpImage];
    
    UIImageView *justLookImage = [[[UIImageView alloc] initWithFrame:CGRectMake(242, 13, 28, 36)] autorelease];
    justLookImage.opaque = YES;
    justLookImage.backgroundColor = [UIColor clearColor];
    // set image TODO
    // set num indicator TODO
    [userHeader addSubview:justLookImage];
    
    UIImageView *helpDoneImage = [[[UIImageView alloc] initWithFrame:CGRectMake(280, 13, 28, 36)] autorelease]; // FIXME a button ?
    helpDoneImage.opaque = YES;
    helpDoneImage.backgroundColor = [UIColor clearColor];
    // set image TODO
    // set num indicator TODO
    [userHeader addSubview:helpDoneImage];
    
    // TODO ....  set all value use usermanager 
    // done butoong 
    // is self?
    
    
    
 
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
