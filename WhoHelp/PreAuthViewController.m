//
//  PreAuthViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PreAuthViewController.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "DoubanAuthViewController.h"

@implementation PreAuthViewController
@synthesize authLinkWeibo=authLinkWeibo_;
@synthesize authLinkDouban=authLinkDouban_;
@synthesize authLinkRenren=authLinkRenren_;

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

#pragma mark - Actions
- (IBAction)linkToAuthDouban:(id)sender
{
    [self authRequest:@"/douban/auth"];
}
- (IBAction)linkToAuthWeibo:(id)sender
{
    [self authRequest:@"/douban/auth"];
}
- (IBAction)linkToAuthRenren:(id)sender
{
    [self authRequest:@"/douban/auth"];
}


- (void)authRequest: (NSString *)path
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?ak=%@", HOST, path, APPKEY2]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];

    DoubanAuthViewController *webVC = [[DoubanAuthViewController alloc] initWithNibName:@"DoubanAuthViewController" bundle:nil];
    //[webVC.webview loadHTMLString:responseString baseURL:request.url];
    webVC.baseURL = request.url;
    webVC.body = responseString;
    [self presentModalViewController:webVC animated:YES];
    
    [webVC release];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", [error description]);
}

#pragma mark - dealloc
- (void)dealloc
{
    [authLinkDouban_ release];
    [authLinkRenren_ release];
    [authLinkWeibo_ release];
    [super dealloc];
}

@end
