//
//  HelpSendViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSendViewController.h"
#import "WhoHelpAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@interface HelpSendViewController (Private)
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
- (void)errorNotification:(NSString *)message;
- (void)warningNotification:(NSString *)message;
@end

@implementation HelpSendViewController

@synthesize helpTabBarController=helpTabBarController_;
@synthesize helpTextView=helpTextView_;
@synthesize numIndicator=numIndicator_;
@synthesize locationIsWork=locationIsWork_;
@synthesize sendBarItem=sendBarItem_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize address=address_;

- (CLLocationManager *) locationManager
{
    if (locationManager_ == nil){
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.delegate = self;
    }
    return locationManager_;
}

- (CLLocation *)curLocation
{
    if (self.locationIsWork){
        //return self.locationManager.location;
        // FIXME now is simulator
        return [[[CLLocation alloc] initWithLatitude:30.293461 longitude:120.160904] autorelease];
    }
    // default location the center of Hangzhou
    return [[[CLLocation alloc] initWithLatitude:30.293461 longitude:120.160904] autorelease];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
    
    return managedObjectContext_;
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
    self.locationIsWork = NO;
    [self.locationManager startUpdatingLocation];
    [self parsePosition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@", @"Shutting down core  location.");
    [self.locationManager stopUpdatingLocation];
    [self.reverseGeocoder cancel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - modal actions
-(IBAction)cancelButtonPressed:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];
    //[[self.helpTabBarController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];

}

- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"help text is sending....");
    [self postHelpTextToRemoteServer];
}

- (void)postHelpTextToRemoteServer
{
    NSLog(@"send now, %@", self.helpTextView.text);
    
    [self.loadingIndicator startAnimating];
    self.sendBarItem.enabled = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://rest.whohelp.me/l/?tk=q1w21&ak=12345678"]];
    
    // make json data for post
    CLLocationCoordinate2D curloc = self.curLocation.coordinate;
    NSMutableDictionary *preLoud = [[NSMutableDictionary alloc] init];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.latitude] forKey:@"lat"];
    [preLoud setObject:[NSNumber numberWithDouble:curloc.longitude] forKey:@"lon"];
    [preLoud setObject:[self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"content"];
    if (self.address != nil){
        [preLoud setObject:self.address forKey:@"address"];
    }
    
    
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:preLoud];
    
    NSLog(@"data: %@", dataString);
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"processing louds...");
    //NSString *responseString = [request responseString];
    NSData *responseData = [request responseData];
    
    // create the json parser 
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    id result = [jsonParser objectWithData:responseData];
    [jsonParser release];
    

    if ([request responseStatusCode] == 200){
        if ([result objectForKey:@"status"] == @"fail"){
            [self warningNotification:@"发送求助失败"];
        } else{
            [self dismissModalViewControllerAnimated:YES];
        }
        
    } else{
        [self warningNotification:@"请求服务出错"];
    }

    // send ok cancel
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@, %@", error, [error userInfo]);
    // notify the user
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    [self warningNotification:@"网络服务请求失败."];

}

- (IBAction)addRewardButtonPressed:(id)sender
{
    NSLog(@"reward button be pressed");
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

#pragma mark - locationmananger delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", @"Core location claims to have a position.");
    self.locationIsWork = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Core locaiton can't get the fix error: %@, %@", error, [error localizedDescription]);
    self.locationIsWork = NO;
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                NSLog(@"Core location denied");
                break;
            case kCLErrorLocationUnknown:
                NSLog(@"Core location unkown");
                break;
                
            default:
                break;
        }   
    } else {
        // We handle all non-CoreLocation errors here
    }   
    
}

#pragma mark - get the address from lat and lon
- (void)parsePosition
{
    // Reverse geocode
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.curLocation.coordinate];
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
}

- (NSString *)getPlaceInfo:(MKPlacemark *)placemark
{
    NSLog(@"look at this");
    return [NSString stringWithFormat:@"%@ %@", 
                placemark.thoroughfare == nil ? @"" : placemark.thoroughfare, 
                placemark.subThoroughfare == nil ? @"" : placemark.subThoroughfare];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"Reverse geo lookup failed with error: %@", [error localizedDescription]);
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
    [locationManager_ release];
    [sendBarItem_ release];
    [managedObjectContext_ release];
    [loadingIndicator_ release];
    [reverseGeocoder_ release];
    [address_ release];
    [super dealloc];
}
@end
