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
@synthesize address=address_;
@synthesize wardButton=wardButton_;
@synthesize helpText=helpText_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize fakeLocation=fakeLocation_;


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
//    self.helpTextView.placeholder = @"你需要的帮助$你提供的报酬";
//    self.helpTextView.placeholderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self fakeParsePosition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.reverseGeocoder cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

#pragma mark - modal actions
-(IBAction)cancelButtonPressed:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction)sendButtonPressed:(id)sender
{
    //[self fakePostHelpTextToRemoteServer];
    [self.loadingIndicator startAnimating];
    [self fakeParsePosition];
}

//- (void)fakePostHelpTextToRemoteServer
//{
//    if ([CLLocationManager locationServicesEnabled]){
//        [[LocationController sharedInstance].locationManager startUpdatingLocation];
//        [self performSelector:@selector(postHelpTextToRemoteServer) withObject:nil afterDelay:3.0];
//    } else{
//        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
//    }       
//}

- (void)postHelpTextToRemoteServer
{
    
    if (NO == [LocationController sharedInstance].allow){
        [Utils tellNotification:@"乐帮需要获取你位置信息的许可，以便提供帮助的人查看你的求助地点。"];
        return;
    }
    
    [self.loadingIndicator startAnimating];
    self.sendBarItem.enabled = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?tk=%@&ak=%@", SENDURI, [ProfileManager sharedInstance].profile.token, APPKEY]];
    
    // make json data for post
    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
//    CLLocationCoordinate2D fakeloc = self.fakeLocation.coordinate;
    //[[LocationController sharedInstance].locationManager stopUpdatingLocation];

    NSMutableDictionary *preLoud = [[NSMutableDictionary alloc] init];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.latitude] forKey:@"lat"];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.longitude] forKey:@"lon"];
//    [preLoud setObject:[NSNumber numberWithDouble:fakeloc.latitude] forKey:@"flat"];
//    [preLoud setObject:[NSNumber numberWithDouble:fakeloc.longitude] forKey:@"flon"];
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
        
    } else if (412 == [request responseStatusCode]){
        [Utils warningNotification:@"每个用户最多可发三条求助信息，请先删除部分求助再发送"];
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"非正常返回"];
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
    [Utils warningNotification:@"网络链接错误"];

}

- (IBAction)addRewardButtonPressed:(id)sender
{
    self.helpTextView.text = [NSString stringWithFormat:@"%@%@", self.helpTextView.text, @"$"];
}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"done the editing change");
    NSInteger nonSpaceTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
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
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    NSLog(@"fuck");
//    return YES;
//}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately

    NSValue *endingFrame = [[notif userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame;
    [endingFrame getValue:&frame];
    
    CGRect numIndicatorFrame = self.numIndicator.frame;
    CGRect wardButtonFrame = self.wardButton.frame;
    CGRect contentFrame = self.helpTextView.frame;
    CGRect helpTextFrame = self.helpText.frame;
    if (frame.size.height == 480.0f){
        
        numIndicatorFrame.origin.y = 320.0f - (frame.size.width + 45.0f);
        wardButtonFrame.origin.y = 320.0f - (frame.size.width + 50.0f);
        contentFrame.size.height = 320.0f - 44.0f - (frame.size.width + 50.0f);
        helpTextFrame.origin.y = 320.0f - (frame.size.width + 50.0f);
    } else {
        
        numIndicatorFrame.origin.y = 480.0f - (frame.size.height + 45.0f);
        wardButtonFrame.origin.y = 480.0f - (frame.size.height + 50.0f);
        contentFrame.size.height = 480.0f - 44.0f - (frame.size.height + 50.0f);
        helpTextFrame.origin.y = 480.0f - (frame.size.height + 50.0f);
    }
    
    self.numIndicator.frame = numIndicatorFrame;
    self.wardButton.frame = wardButtonFrame;
    self.helpTextView.frame = contentFrame;
    self.helpText.frame = helpTextFrame;

}

#pragma mark - get the address from lat and lon
- (void)fakeParsePosition
{
    if ([CLLocationManager locationServicesEnabled]){
        self.sendBarItem.enabled = NO;
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        [self performSelector:@selector(parsePosition) withObject:nil afterDelay:3.0];
    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    } 
    
}

- (void)retriveFakeLocation: (CLLocation *)location
{
    // real one
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%f,%f", POSURI, location.coordinate.latitude, location.coordinate.longitude]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error && (200 == [request responseStatusCode])) {
        
        // create the json parser 
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary *pos = [jsonParser objectWithData:[request responseData]];
        [jsonParser release];
        self.fakeLocation = [[CLLocation alloc] initWithLatitude:[[pos objectForKey:@"lat"] doubleValue] longitude:[[pos objectForKey:@"lon"] doubleValue]];
    } else {
        self.fakeLocation = location;
    }
    
}

- (void)parsePosition
{
    // Reverse geocode
    [self retriveFakeLocation:[LocationController sharedInstance].location];
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    // Get the fake location
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.fakeLocation.coordinate];
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
    [self postHelpTextToRemoteServer];
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
    [self postHelpTextToRemoteServer];
}

#pragma mark - dealloc
- (void)dealloc
{
    [helpTextView_ release];
    [helpTabBarController_ release];
    [numIndicator_ release];
    [sendBarItem_ release];
    [loadingIndicator_ release];
    [address_ release];
    [wardButton_ release];
    [reverseGeocoder_ release];
    [fakeLocation_ release];
    [helpText_ release];
    [super dealloc];
}
@end
