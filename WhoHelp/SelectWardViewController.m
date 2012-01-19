//
//  SelectWardViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectWardViewController.h"
#import "CustomItems.h"

@implementation SelectWardViewController

@synthesize hlVC=hlVC_;
@synthesize wardTextField=wardTextField_;
@synthesize tableView=tableView_;

- (void)dealloc
{
    [wardCategories_ release];
    [wardTextField_ release];
    [hlVC_ release];
    [tableView_ release];
    [super dealloc];
}

- (NSArray *)wardCategories
{
    if (wardCategories_ == nil){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"PayCate" ofType:@"plist"];
        NSDictionary *payCates = [NSDictionary dictionaryWithContentsOfFile:myFile]; 
        NSArray *sortedArray = [[payCates allValues] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2){
            int dnum1 = [[d1 objectForKey:@"no"] intValue];
            int dnum2 = [[d2 objectForKey:@"no"] intValue];
            return dnum1 > dnum2;
        }];
        
        wardCategories_ = [[NSArray alloc] initWithObjects: sortedArray, nil]; 
    }
    return wardCategories_;
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"你的报酬"] autorelease];
    
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
}

-(void)backAction:(id)sender
{
     self.hlVC.wardText = self.wardTextField.text;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // add event to detect the keyboard show.
    // so it can change the size of the text input.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}

# pragma mark - keyboard show event for resize the UI
- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    NSValue *endingFrame = [[notif userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame;
    [endingFrame getValue:&frame];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = 370.0f - frame.size.height;
    
    self.tableView.frame = tableFrame;
    
}

#pragma mark - dimiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = 370.0f;
    self.tableView.frame = tableFrame;
    
    return YES;
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
    return [self.wardCategories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[self.wardCategories objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"payCateCell";
    
    PayCateTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PayCateTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *wardCategory = [[self.wardCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.title.text = [wardCategory objectForKey:@"text"];
    cell.logo.image = [UIImage imageNamed:[wardCategory objectForKey:@"logo"]];
    
    return cell;
}

#pragma mark - Table view data source

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
    title.text = @"选择报酬类型"; 
    [sectionView addSubview:title];
    
    return sectionView;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.hlVC.wardCategory = [[self.wardCategories objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    //[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
