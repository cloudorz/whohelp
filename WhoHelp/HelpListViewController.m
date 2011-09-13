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
- (NSDictionary *)getLoudByLid:(NSNumber *)lid;
@end

@implementation HelpListViewController

@synthesize profiles=profiles_;
@synthesize newLouds=newLouds_;

- (NSManagedObjectContext *)managedObjectContext
{
    WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    return managedObjectContext;
}

- (NSFetchedResultsController *)resultsController
{
    // If we already init the resutls controller, just return it.
    if (resultsController_ != nil){
        return resultsController_;
    }
    
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
    
    // create the fetch results controller 
    resultsController_ = [[NSFetchedResultsController alloc] 
                          initWithFetchRequest:request 
                          managedObjectContext:self.managedObjectContext 
                          sectionNameKeyPath:nil 
                          cacheName:@"loud_list.cache"];
    resultsController_.delegate = self;
    
    NSError *error;
    BOOL sucess = [resultsController_ performFetch:&error];
    if (!sucess){
        // Handle the error
        // TODO error maybe
        NSLog(@"fetch the loud list error: %@, %@", error, [error userInfo]);
    }
    [request release];
    return resultsController_;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
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
    [self fetchLoudList];

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
    return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[[self.resultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Loud *loud = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = loud.content;
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
    
     HelpDetailViewController *detailViewController = [[HelpDetailViewController alloc] initWithNibName:@"HelpDetailViewController" bundle:nil];
     // ...
    detailViewController.loud = [self.resultsController objectAtIndexPath:indexPath];
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     
}

#pragma mark - RESTful request
- (void)fetchLoudList
{
    NSURL *url = [NSURL URLWithString:@"http://rest.whohelp.me/l/list?tk=q1w21&ak=12345678"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
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
            NSLog(@"remote error: %@, %@", [request responseStatusCode], [request responseStatusMessage]);
        } else{
            if ([result isKindOfClass:[NSMutableDictionary class]] &&
                [result objectForKey:@"status"] == @"fail"){
                NSLog(@"%@", @"The operation failed.");
                
            } else {
                self.newLouds = result;
                [self addLouds]; // save data to database
            }
        }

        
    } else {
        // error handle TODO
        NSLog(@"louds json parser error: %@, %@", error, [error userInfo]);
    }
}

- (void)syncLoudList
{
    // TODO instead of the fetch method.
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // error handle TODO
    NSLog(@"error: %@, %@", error, [error userInfo]);
}

#pragma mark - CRUD Loud and Profile

- (void)addLouds
{
    if (self.newLouds == nil){
        return;
    }
    
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
        // Handle the error. TODO
        NSLog(@"save data error: %@, %@", error, [error userInfo]);
    }
    
    [dateFormatter release];
}


- (NSDictionary *)getLoudByLid:(NSNumber *)lid
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
        // Handle the error
        NSLog(@"get by lid error: %@, %@", error, [error userInfo]);
    }

    return nil;
    
}



#pragma mark - dealloc 
- (void)dealloc
{
    [profiles_ release];
    [resultsController_ release];
    [managedObjectContext_ release];
    [super dealloc];
}

@end
