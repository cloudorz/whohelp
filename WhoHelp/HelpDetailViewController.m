//
//  HelpDetailViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpDetailViewController.h"

@implementation HelpDetailViewController

@synthesize loud=loud_;
@synthesize nameLabel=nameLabel_;
@synthesize locationLabel=locaitonLabel_;
@synthesize timeLabel=timeLabel_;
@synthesize avatarImage=avatarImage_;
@synthesize contentTextView=contentTextView_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize loadingIndicator=loadingIndicator_;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if (self.loud.userAvatar != nil){
        self.avatarImage.image = [UIImage imageWithData:self.loud.userAvatar];
    }
    self.nameLabel.text = self.loud.userName;
    self.contentTextView.text = self.loud.content;
    // get the geocoder address 
    [self parsePosition];
    self.timeLabel.text = [self descriptionForTime:self.loud.created];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - get the address from lat and lon
- (void)parsePosition
{
    // use the location get the address description
    // start loading
    [self.loadingIndicator startAnimating];
    // Reverse geocode
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.loud.lon doubleValue], [self.loud.lat doubleValue])];
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
}

- (NSString *)descriptionForTime:(NSDate *)date
{
    // convert the time formate to human reading. TODOs
    return [date description];
}

#pragma mark - the tab bar operation

- (void)tabBar: (UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    switch (item.tag) {
        case 1:
        {
            NSLog(@"Let me back.");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2:
        {
            // Go to case 3 handle.
        }
        case 3:
        {
            NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%d", item.tag == 2 ? @"tel" : @"sms", self.loud.userPhone]];
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
                [[UIApplication sharedApplication] openURL:callURL];
            } else {
                UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"警告" message:@"你的设备不支持这项功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [Notpermitted show];
                [Notpermitted release];
            }
            break;
        }   
        default:
            NSLog(@"Nothing to do");
            break;
    }
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

#pragma mark - reverser mehtod
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"Reverse geo lookup failed with error: %@", [error localizedDescription]);
    [self.reverseGeocoder cancel];
    // stop loading status
    [self.loadingIndicator stopAnimating];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSLog(@"Got it");
    //NSDictionary *p = placemark.addressDictionary;
    NSLog(@"street address: %@", placemark.thoroughfare);
    NSLog(@"street-level: %@", placemark.subThoroughfare);
    NSLog(@"city-level: %@", placemark.subLocality);
    NSLog(@"city address: %@", placemark.locality);
    self.locationLabel.text = [NSString stringWithFormat:@"%@ %@", 
                               placemark.thoroughfare == nil ? @"" : placemark.thoroughfare, 
                               placemark.subThoroughfare == nil ? @"" : placemark.subThoroughfare];
    // stop loading status
    [self.loadingIndicator stopAnimating];
    [self.reverseGeocoder cancel];
}

#pragma mark - dealloc
- (void)dealloc
{
    [locaitonLabel_ release];
    [loud_ release];
    [nameLabel_ release];
    [timeLabel_ release];
    [contentTextView_ release];
    [avatarImage_ release];
    [reverseGeocoder_ release];
    [loadingIndicator_ release];
    [super dealloc];
}

@end
