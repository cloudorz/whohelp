//
//  HelpSendViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSendViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"
#import "ProfileManager.h"


@implementation HelpSendViewController

@synthesize helpTabBarController=helpTabBarController_;
@synthesize helpTextView=helpTextView_;
@synthesize numIndicator=numIndicator_;
@synthesize sendBarItem=sendBarItem_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize address=address_;


- (Profile *)profile
{
    if (nil == profile_){
        profile_ = [[ProfileManager sharedInstance] profile];
    }
    
    return profile_;
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
    // display the keyboard
    [self.helpTextView becomeFirstResponder];
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
    //[[LocationController sharedInstance].locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fakeParsePosition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[LocationController sharedInstance].locationManager stopUpdatingLocation];
    [self.reverseGeocoder cancel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
  
//    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
//        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        CGRect frame = self.helpTextView.frame;
//        frame.size.height = 80.0f;
//        self.helpTextView.frame = frame;
//        
//    } else{
//        self.helpTextView.frame = self.curFrame;
//        self.helpTextView.contentSize = self.curSize;
//    }
    
    return YES;
}

#pragma mark - modal actions
-(IBAction)cancelButtonPressed:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction)sendButtonPressed:(id)sender
{
    [self postHelpTextToRemoteServer];
}

- (void)postHelpTextToRemoteServer
{
    
    [self.loadingIndicator startAnimating];
    self.sendBarItem.enabled = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?tk=%@&ak=%@", SENDURI, self.profile.token, APPKEY]];
    
    // make json data for post
    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;

    NSMutableDictionary *preLoud = [[NSMutableDictionary alloc] init];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.latitude] forKey:@"lat"];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.longitude] forKey:@"lon"];
    [preLoud setObject:[self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"content"];
    if (self.address != nil){
        [preLoud setObject:self.address forKey:@"address"];
    }
    
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:preLoud];
    [preJson release];
    [preLoud release];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    if ([request responseStatusCode] == 201){
        [self dismissModalViewControllerAnimated:YES];
        
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"请求服务出错"];
    }

    // send ok cancel
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    [Utils warningNotification:@"网络服务请求失败."];

}

- (IBAction)addRewardButtonPressed:(id)sender
{
    self.helpTextView.text = [NSString stringWithFormat:@"%@%@", self.helpTextView.text, @"$"];
}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"done the editing change");
    NSInteger nonSpaceTextLength = [[self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    self.numIndicator.text = [NSString stringWithFormat:@"%d", 70 - nonSpaceTextLength/*[self.helpTextView.text length]*/];
    if (nonSpaceTextLength <= 0) {
        self.sendBarItem.enabled = NO;
    } else{
        self.sendBarItem.enabled = YES;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        return NO;
    }
    
    return YES;
}


#pragma mark - get the address from lat and lon
- (void)fakeParsePosition
{

    [[LocationController sharedInstance].locationManager startUpdatingLocation];
    [self performSelector:@selector(parsePosition) withObject:nil afterDelay:1.5];
        
}

- (void)parsePosition
{
    // Reverse geocode
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:[LocationController sharedInstance].location.coordinate];
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
}

- (NSString *)getPlaceInfo:(MKPlacemark *)placemark
{

    return [NSString stringWithFormat:@"%@ %@", 
                placemark.thoroughfare == nil ? @"" : placemark.thoroughfare, 
                placemark.subThoroughfare == nil ? @"" : placemark.subThoroughfare];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //NSLog(@"Reverse geo lookup failed with error: %@", [error localizedDescription]);
    [self.reverseGeocoder cancel];
    // stop loading status
    self.address = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    //    NSLog(@"Got it");
    //    //NSDictionary *p = placemark.addressDictionary;
    //    NSLog(@"street address: %@", placemark.thoroughfare);
    //    NSLog(@"street-level: %@", placemark.subThoroughfare);
    //    NSLog(@"city-level: %@", placemark.subLocality);
    //    NSLog(@"city address: %@", placemark.locality);
    
    // stop loading status
    [self.reverseGeocoder cancel];
    self.address = [self getPlaceInfo:placemark];
}



#pragma mark - dealloc
- (void)dealloc
{
    [helpTextView_ release];
    [helpTabBarController_ release];
    [numIndicator_ release];
    [sendBarItem_ release];
    [loadingIndicator_ release];
    [reverseGeocoder_ release];
    [address_ release];
    [super dealloc];
}
@end
