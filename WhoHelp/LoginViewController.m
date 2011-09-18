//
//  LoginViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "WhoHelpAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation LoginViewController

@synthesize loadingIndicator=loadingIndicator_;
@synthesize name=name_;
@synthesize pass=pass_;

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
    
    return managedObjectContext_;
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [tap release];
    // Do any additional setup after loading the view from its nib.
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.loadingIndicator stopAnimating];
}

#pragma mark - action login forgot password
- (IBAction)loginButtonPressed:(id)sender
{
    NSLog(@"%@", @"login request");
}

- (IBAction)forgotPasswordButtonPressed:(id)sender
{
    NSLog(@"%@", @"jump to reset password view");
}

- (IBAction)signupButtonPressed:(id)sender
{
    NSLog(@"%@", @"jump to signup view");
}

-(void)dismissKeyboard {
    [self.name resignFirstResponder];
    [self.pass resignFirstResponder];
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
    NSLog(@"Got here");
}

#pragma mark - dealloc
- (void)dealloc
{
    [managedObjectContext_ release];
    [name_ release];
    [pass_ release];
    [loadingIndicator_ release];
    [super dealloc];
}

@end
