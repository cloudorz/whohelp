//
//  ChangPassswordViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ChangPassswordViewController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "Utils.h"
#import "LoginViewController.h"
#import "WhoHelpAppDelegate.h"
#import "ProfileManager.h"

@implementation ChangPassswordViewController

@synthesize oldPassword=oldPassword_;
@synthesize password=password_;
@synthesize repeatPassword=repeatPassword_;
@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;


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
    if ([ProfileManager sharedInstance].profile.isLogin == NO){
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
    
    if ([self.oldPassword.text isEqual:@""] || 
        [self.password.text isEqual:@""] || 
        [self.repeatPassword.text isEqual:@""]
        ){
        
        self.errorLabel.attributedText = [Utils wrongInfoString:@"下面三项必须填写"];
        
        return;
    }
    
    if (![self.password.text isEqual:self.repeatPassword.text]){

        self.errorLabel.attributedText = [Utils wrongInfoString:@"新密码输入不一致"];
        
        return;
    }
    
    self.errorLabel.attributedText = nil;
    
    NSMutableDictionary *passwords = [[NSMutableDictionary alloc] init];
    [passwords setObject:self.oldPassword.text forKey:@"old_password"];
    [passwords setObject:self.password.text forKey:@"password"];
    
    [self.loadingIndicator startAnimating];
    [self postPasswordInfo:passwords];
    [self.loadingIndicator stopAnimating];
    [passwords release];
}


- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images
- (void)postPasswordInfo: (NSMutableDictionary *)passwordInfo
{

    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:passwordInfo];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@&tk=%@", USERURI, [ProfileManager sharedInstance].profile.phone, APPKEY, [ProfileManager sharedInstance].profile.token]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"PUT"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
       
            [[ProfileManager sharedInstance] logout];

            [self.navigationController popViewControllerAnimated:NO];
            
        } else if (412 == [request responseStatusCode]){
            
            self.errorLabel.attributedText = [Utils wrongInfoString:@"密码不正确"];

        } else if (403 == [request responseStatusCode]) {
            [Utils warningNotification:@"手机号禁止修改"];
        } else{
            [Utils warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [Utils warningNotification:@"网络链接错误"];
    }
}


#pragma mark - dealloc
- (void)dealloc
{
    [oldPassword_ release];
    [password_ release];
    [repeatPassword_ release];
    [errorLabel_ release];
    [loadingIndicator_ release];
    [super dealloc];
}

@end
