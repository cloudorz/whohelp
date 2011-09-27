//
//  ChangNameViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ChangNameViewController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "WhoHelpAppDelegate.h"

@implementation ChangNameViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize newName=newName_;
@synthesize profile=profile_;

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
    [self.loadingIndicator stopAnimating];
    // Do any additional setup after loading the view from its nib.
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
    self.newName.text = self.profile.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

#pragma mark - actions on view
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender
{
    NSMutableAttributedString *attributedString;
    if ([self.newName.text isEqualToString:@""]){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"名字不能为空"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
        
        return;
    }
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:self.newName.text forKey:@"name"];
    
    [self.loadingIndicator startAnimating];
    [self postNameInfo:info];
    [self.loadingIndicator stopAnimating];
    
    [info release];
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images
- (void)postNameInfo: (NSMutableDictionary *)nameInfo
{
    [self.loadingIndicator startAnimating];
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:nameInfo];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@&tk=%@", USERURI, self.profile.phone, APPKEY, self.profile.token]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"PUT"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){

            self.profile.name = [nameInfo objectForKey:@"name"];
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) { 
                [self warningNotification:@"数据存储失败."];
            }else{
                [self.navigationController popViewControllerAnimated:NO];
            }
            
        } else if (403 == [request responseStatusCode]){
            [self warningNotification:@"非法操作"];
        } else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

#pragma mark - handling errors
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message
{
    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [Notpermitted show];
    [Notpermitted release];
}

- (void)warningNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"警告" forMessage:message];
}

- (void)errorNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"错误" forMessage:message];  
}

- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [newName_ release];
    [super dealloc];
}
@end
