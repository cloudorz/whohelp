//
//  SelectDateViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectDateViewController.h"

@implementation SelectDateViewController

@synthesize duetimePicker=duetimePicker_;
@synthesize hlVC=hlVC_;

-(void)dealloc
{
    [duetimePicker_ release];
    [hlVC_ release];
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
    self.navigationItem.title = @"有效期";
    self.duetimePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:1800];
    self.duetimePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:3600*24*14];
    self.duetimePicker.date = [[NSDate date] dateByAddingTimeInterval:3600*24];
    self.duetimePicker.minuteInterval = 10;
    self.duetimePicker.timeZone = [NSTimeZone localTimeZone];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //NSLog(@"%@", [self.duetimePicker.date descriptionWithLocale:[NSTimeZone localTimeZone]]);
    self.hlVC.duetime = self.duetimePicker.date;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
