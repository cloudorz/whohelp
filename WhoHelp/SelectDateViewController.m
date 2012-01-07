//
//  SelectDateViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectDateViewController.h"
#import "CustomItems.h"

@implementation SelectDateViewController

@synthesize duetimePicker=duetimePicker_;
@synthesize hlVC=hlVC_;
@synthesize timeLabel=timeLabel_;

-(void)dealloc
{
    [duetimePicker_ release];
    [hlVC_ release];
    [timeLabel_ release];
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
    [self.duetimePicker addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self valueChanged:self.duetimePicker];
    

    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"设置有效期"] autorelease];
    
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
}

- (void)backAction:(id)sender
{
    self.hlVC.duetime = self.duetimePicker.date;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)valueChanged:(id)sender
{
    
    self.timeLabel.text = [NSDateFormatter localizedStringFromDate:self.duetimePicker.date 
                                                         dateStyle:NSDateFormatterShortStyle 
                                                         timeStyle:NSDateFormatterShortStyle];
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

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
