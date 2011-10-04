//
//  ResetPasswordViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"

@implementation ResetPasswordViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize phone=phone_;

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
    
    [sender setEnabled:NO];
    
    NSString *decimalRegex = @"^1[358][0-9]{9}$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    if ([decimalTest evaluateWithObject:self.phone.text]){
        [self.loadingIndicator startAnimating];
        [self resetPasswordInfo:self.phone.text];

    }else{

        self.errorLabel.attributedText = [Utils wrongInfoString:@"请输入正确的手机号(11位)"];
    }
    
    
    [sender setEnabled:YES];
    
}

#pragma mark - get the images
- (void)resetPasswordInfo: (NSString *)phone
{
    [self.loadingIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@", RESETURI, phone, APPKEY]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if ([request responseStatusCode] == 200){
        
        [self dismissModalViewControllerAnimated:YES];
        
    } else if (404 == [request responseStatusCode]) {
  
        self.errorLabel.attributedText = [Utils wrongInfoString:@"手机号未注册"];
    } else{
        [Utils warningNotification:@"服务器异常返回"];
    }
    [self.loadingIndicator stopAnimating];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [Utils warningNotification:@"网络链接错误"];
    [self.loadingIndicator stopAnimating];
}

- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [phone_ release];
    [super dealloc];
}

@end
