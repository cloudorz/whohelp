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
#import "Config.h"
#import "Utils.h"


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

- (Profile *)profile
{
    
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isLogin == YES"]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            
            NSManagedObject *res = [mutableFetchResults objectAtIndex:0];
            profile_ = (Profile *)res;
        }
        
    } else {
        // Handle the error FIXME
        NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
    }
    
    [mutableFetchResults release];
    
    return profile_;
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


#pragma mark - locationmananger delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", @"Core location claims to have a position.");
    self.locationIsWork = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"Core locaiton can't get the fix error: %@, %@", error, [error localizedDescription]);
    self.locationIsWork = NO;
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                [Utils warningNotification:@"Core location denied"];
                break;
            case kCLErrorLocationUnknown:
                [Utils warningNotification:@"Core location unkown"];
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
    [locationManager_ release];
    [sendBarItem_ release];
    //[managedObjectContext_ release];
    [loadingIndicator_ release];
    [reverseGeocoder_ release];
    [address_ release];
    [super dealloc];
}
@end
