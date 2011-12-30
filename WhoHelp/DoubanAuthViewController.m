//
//  DoubanAuthViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DoubanAuthViewController.h"
#import "Config.h"
#import "Utils.h"
#import "SBJson.h"
#import "ProfileManager.h"

@implementation DoubanAuthViewController

@synthesize webview=webview_;
@synthesize loading=loading_;
@synthesize baseURL=baseURL_;
@synthesize body=body_;

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
    self.webview.scalesPageToFit =NO;
    self.webview.delegate = self;
    [self.loading stopAnimating];
    
    [self.webview loadHTMLString:self.body baseURL:self.baseURL];
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
            [Utils warningNotification:[error localizedDescription]];
        } else {
             //NSLog(@"fuck: %@", content);
            // create the json parser 
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSMutableDictionary *info = [jsonParser objectWithString:content];
            [jsonParser release];            
            [[ProfileManager sharedInstance] saveUserInfo:info];
            

            [self dismissModalViewControllerAnimated:NO];// Animated must be 'NO', I don't why...
            [[NSNotificationCenter  defaultCenter] postNotificationName:@"DismissPreAuthVC" object:nil];

        }
        
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    [webview_ release];
    [loading_ release];
    [baseURL_ release];
    [body_ release];
    [super dealloc];
}

@end
