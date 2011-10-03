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
#import "Utils.h"
#import "LoginViewController.h"
#import "ProfileManager.h"

@implementation DeleteAccountViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize password=password_;


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
    if (nil == [ProfileManager sharedInstance].profile){
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
    
    [self.loadingIndicator startAnimating];
    [self  delAccount2];
    [self.loadingIndicator stopAnimating];
    
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images

- (void)delAccount2
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@&tk=%@&pw=%@", USERURI, [ProfileManager sharedInstance].profile.phone, APPKEY, [ProfileManager sharedInstance].profile.token, self.password.text]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"DELETE"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
   
            [[ProfileManager sharedInstance] del];

            [self.navigationController popViewControllerAnimated:NO];

        } else if (403 == [request responseStatusCode]) {
            
            NSMutableAttributedString *attributedString;
            attributedString = [NSMutableAttributedString attributedStringWithString:@"非法操作"];
            [attributedString setFont:[UIFont systemFontOfSize:14.0]];
            [attributedString setTextColor:[UIColor redColor]];
            self.errorLabel.attributedText = attributedString;
            
        } else if (412 == [request responseStatusCode]){
            NSMutableAttributedString *attributedString;
            attributedString = [NSMutableAttributedString attributedStringWithString:@"密码错误"];
            [attributedString setFont:[UIFont systemFontOfSize:14.0]];
            [attributedString setTextColor:[UIColor redColor]];
            self.errorLabel.attributedText = attributedString;
        }else{
            [Utils warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [Utils warningNotification:@"请求服务错误"];
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
