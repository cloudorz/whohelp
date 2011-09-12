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
    self.locationLabel.text = [self addressFromLocationLon:self.loud.lon locationLat:self.loud.lat];
    self.timeLabel.text = [self descriptionForTime:self.loud.created];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - get the address from lat and lon
- (NSString *)addressFromLocationLon:(NSNumber *)lon locationLat:(NSNumber *)lat
{
    // use the location get the address description TODO
    return @"test address";
}

- (NSString *)descriptionForTime:(NSDate *)date
{
    // convert the time formate to human reading. TODOs
    return [date description];
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
    [super dealloc];
}

@end
