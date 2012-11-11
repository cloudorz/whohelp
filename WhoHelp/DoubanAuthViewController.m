//
//  DoubanAuthViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DoubanAuthViewController.h"
#import "Utils.h"
#import "SBJson.h"
#import "ProfileManager.h"
#import "UIViewController+msg.h"
#import "CustomItems.h"

@implementation DoubanAuthViewController

@synthesize webview=_webview;
@synthesize loading=_loading;
//@synthesize baseURL=_baseURL;
//@synthesize body=_body;
@synthesize cusNavigationItem=_cusNavigationItem;


- (void)dealloc
{
    // must set delegate to nil
    // or that's a bug, crash
    self.webview.delegate = nil; 
    
    [_webview release];
    [_loading release];
//    [_baseURL release];
//    [_body release];
    [_cusNavigationItem release];
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
//    self.webview.scalesPageToFit =NO;
    self.webview.delegate = self;
    
    [self.loading stopAnimating];
     self.cusNavigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"用微博登录乐帮"] autorelease];
    self.cusNavigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(cancelAuth:)] autorelease];
    
//    [self.webview loadHTMLString:self.body baseURL:self.baseURL];
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, @"/auth/weibo"]];
     [self.webview loadRequest: [NSURLRequest requestWithURL:url]];
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

#pragma mark - back action
- (IBAction)cancelAuth:(id)sender
{
  
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter  defaultCenter] postNotificationName:@"cancelLogin" object:nil];

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

- (void)clearCookies
{
    // clear the cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }

}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    if ([[[request URL] query] hasPrefix:@"code"]){
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
                [self clearCookies];
                [[ProfileManager sharedInstance] saveUserInfo:authInfo];
                [self dismissModalViewControllerAnimated:YES];// Animated must be 'NO', I don't why...            
//                [[NSNotificationCenter  defaultCenter] postNotificationName:@"DismissPreAuthVC" object:nil];
                
            } else{
                [Utils warningNotification:@"授权失败"];
                [self clearCookies];
                [self dismissModalViewControllerAnimated:YES];     
            }


        }
        
        return NO;
    }

    return YES;
}

@end
