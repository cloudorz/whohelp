//
//  AuthPageViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AuthPageViewController.h"
#import "SBJson.h"
#import "Utils.h"
#import "CustomItems.h"
#import "Config.h"
#import "ProfileManager.h"

@implementation AuthPageViewController

@synthesize webview=webview_;
@synthesize loading=loading_;
@synthesize baseURL=baseURL_;
@synthesize body=body_;

- (void)dealloc
{
    // must set delegate to nil
    // or that's a bug, crash
    
    [webview_ release];
    [loading_ release];
    [baseURL_ release];
    [body_ release];
    [super dealloc];
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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // Do any additional setup after loading the view from its nib.
    self.webview.scalesPageToFit =NO;
    self.webview.delegate = self;
    [self.loading stopAnimating];
    
    [self.webview loadHTMLString:self.body baseURL:self.baseURL];
    
    // navigation item config
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
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

#pragma mark - actions
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - web view delegates
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loading startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loading stopAnimating];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (102 != [error code]){
        [Utils warningNotification:[error localizedDescription]];
    }
    [self.loading stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[NSString stringWithFormat:@"%@://%@", [[request URL] scheme], [[request URL] host]] isEqual:HOST]){
        NSError *error;
        NSString *content = [NSString stringWithContentsOfURL:[request URL] 
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
        
        if (!error){

            [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
        } else {
            //NSLog(@"fuck: %@", content);
            // create the json parser 
            NSMutableDictionary *authInfo = [content JSONValue];
            if (authInfo != nil && authInfo.count > 0 && 
                [authInfo objectForKey:@"userkey"] != nil && 
                [authInfo objectForKey:@"secret"] != nil){
                
                [[ProfileManager sharedInstance] saveUserInfo:authInfo];
                
            } else{
                [Utils warningNotification:@"授权失败!"];   
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
        return NO;
    }
    
    return YES;
}

@end
