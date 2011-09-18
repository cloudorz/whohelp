//
//  HelpSendViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface HelpSendViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate, MKReverseGeocoderDelegate>
{
@private
    UITabBarController *helpTabBarController_;
    UITextView *helpTextView_;
    UILabel *numIndicator_;
    UIBarItem *sendBarItem_;
    
    CLLocationManager *locationManager_;
    BOOL locationIsWork_;
    
    NSManagedObjectContext *managedObjectContext_;
    UIActivityIndicatorView *loadingIndicator_;
    
    MKReverseGeocoder *reverseGeocoder_;
    NSString *address_;
    
}

@property (nonatomic, retain) UITabBarController *helpTabBarController;
@property (nonatomic, retain) IBOutlet UITextView *helpTextView;
@property (nonatomic, retain) IBOutlet UILabel *numIndicator;
@property (nonatomic, retain) IBOutlet UIBarItem *sendBarItem;
@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, readonly) CLLocation *curLocation;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;
@property (nonatomic, retain) NSString *address;
@property BOOL locationIsWork;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)addRewardButtonPressed:(id)sender;
- (void)postHelpTextToRemoteServer;
- (void)parsePosition;

@end
