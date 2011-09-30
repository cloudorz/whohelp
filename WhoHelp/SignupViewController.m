//
//  SignupViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SignupViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"
#import "Signup2ViewController.h"
#import "LoginViewController.h"
#import "WhoHelpAppDelegate.h"

@implementation SignupViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize phone=phone_;
@synthesize code=code_;
@synthesize checked=checked_;
@synthesize codeLabel=codeLabel_;
@synthesize codeString=codeString_;
@synthesize resendButton=resendButton_;

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

    self.codeLabel.hidden = YES;
    self.code.hidden = YES;

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.checked){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        Signup2ViewController *s2VC = [[Signup2ViewController alloc] initWithNibName:@"Signup2ViewController" bundle:nil];
        s2VC.phone = self.phone.text;
        [appDelegate.tabBarController.modalViewController presentModalViewController:s2VC animated:YES];
        [s2VC release];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions on view
- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender
{
    
    [self.loadingIndicator startAnimating];
    [sender setEnabled:NO];
    
    NSMutableAttributedString *attributedString;
    NSString *decimalRegex = @"^1[358][0-9]{9}$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    if ([decimalTest evaluateWithObject:self.phone.text]){
        if (YES == self.code.hidden){
            [self sendSignupCode];
        }else{
            if ([self.code.text isEqualToString:self.codeString]){
                self.checked = YES;
                [self dismissModalViewControllerAnimated:NO];
             
            }else{
                attributedString = [NSMutableAttributedString attributedStringWithString:@"验证码不正确"];
                [attributedString setFont:[UIFont systemFontOfSize:14.0]];
                [attributedString setTextColor:[UIColor redColor]];
                self.errorLabel.attributedText = attributedString;
                
                UIButton *entryButton = [UIButton buttonWithType:UIButtonTypeCustom];
                entryButton.frame = CGRectMake(184, 161, 60, 20);
                
                entryButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
                entryButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
                
                [entryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [entryButton setTitle:@"重新发送" forState:UIControlStateNormal];
                [entryButton setTitleColor:[UIColor colorWithRed:141/255.0 green:210/255.0 blue:95/255.0 alpha:1.0] forState:UIControlStateNormal];
                [entryButton addTarget:self action:@selector(resendCode:) forControlEvents:UIControlEventTouchUpInside];
                self.resendButton = entryButton;
                [self.view addSubview:entryButton];
                self.resendButton.enabled = YES;
            }
        }

    }else{
        attributedString = [NSMutableAttributedString attributedStringWithString:@"请输入正确的手机号(11位)"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    }
    
    [self.loadingIndicator stopAnimating];
    [sender setEnabled:YES];
    
}

- (IBAction)resendCode:(id)sender
{
    [self.loadingIndicator startAnimating];
    [self sendSignupCode];
    [self.loadingIndicator stopAnimating];
}

#pragma mark - get the images
- (void)sendSignupCode
{
    [self.loadingIndicator startAnimating];
    
    self.codeString = [self genRandStringLength:4];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:self.codeString forKey:@"code"];
    [info setObject:self.phone.text forKey:@"phone"];
    
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:info];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?ak=%@", CODEURI, APPKEY]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    // Use when fetching binary data
    
    if ([request responseStatusCode] == 200){

        self.phone.enabled = NO;
        self.codeLabel.hidden = NO;
        self.code.hidden = NO;
        if (nil != self.resendButton){
            [self.resendButton removeFromSuperview];
        }
    }else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    }else if (409 == [request responseStatusCode]) {
        NSMutableAttributedString *attributedString;
        attributedString = [NSMutableAttributedString attributedStringWithString:@"手机号已注册"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    } else{
        [Utils warningNotification:@"服务器异常返回"];
    }
   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
    [Utils warningNotification:@"请求服务错误"];
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

#pragma mark - random number

- (NSString *)genRandStringLength:(int)len 
{
    //NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *letters = @"0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
         }
         
    return randomString;
         
}

- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [phone_ release];
    [code_ release];
    [codeLabel_ release];
    [codeString_ release];
    [resendButton_ release];
    [super dealloc];
}

@end
