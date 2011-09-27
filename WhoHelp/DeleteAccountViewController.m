//
//  DeleteAccountViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DeleteAccountViewController.h"
#import "WhoHelpAppDelegate.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "LoginViewController.h"

@implementation DeleteAccountViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize password=password_;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (nil == self.profile){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        LoginViewController *helpLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [appDelegate.tabBarController presentModalViewController:helpLoginVC animated:YES];
        [helpLoginVC release];
    }
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
    if ([self.password.text isEqualToString:@""]){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"密码不能为空"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
        
        return;
    }
    NSMutableDictionary *passwordInfo = [[NSMutableDictionary alloc] init];
    [passwordInfo setObject:self.password.text forKey:@"password"];
    
    [self.loadingIndicator startAnimating];
    [self  delAccount:passwordInfo];
    [self.loadingIndicator stopAnimating];
    
    [passwordInfo release];
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images
- (void)delAccount: (NSMutableDictionary *)passwordInfo
{

//    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
//    NSString *dataString = [preJson stringWithObject:passwordInfo];
//    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@/passwd?ak=%@&tk=%@&pw=%@", USERURI, self.profile.phone, APPKEY, self.profile.token, [passwordInfo objectForKey:@"password"]]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            
            [self delAccount2];
            
        } else if (406 == [request responseStatusCode]){
            
            NSMutableAttributedString *attributedString;
            attributedString = [NSMutableAttributedString attributedStringWithString:@"密码或手机号错误"];
            [attributedString setFont:[UIFont systemFontOfSize:14.0]];
            [attributedString setTextColor:[UIColor redColor]];
            self.errorLabel.attributedText = attributedString;
            
        }else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

- (void)delAccount2
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@&tk=%@", USERURI, self.profile.phone, APPKEY, self.profile.token]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"DELETE"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
   
            [self.managedObjectContext deleteObject:self.profile];
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) { 
                [self warningNotification:@"数据存储失败."];
            }else{
                self.profile = nil;
                [self.navigationController popViewControllerAnimated:NO];
            }
            
        } else if (403 == [request responseStatusCode]) {
            
            NSMutableAttributedString *attributedString;
            attributedString = [NSMutableAttributedString attributedStringWithString:@"非法操作"];
            [attributedString setFont:[UIFont systemFontOfSize:14.0]];
            [attributedString setTextColor:[UIColor redColor]];
            self.errorLabel.attributedText = attributedString;
            
        }else{
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
    [password_ release];
    [super dealloc];
}

@end