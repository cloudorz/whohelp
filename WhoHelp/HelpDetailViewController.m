//
//  HelpDetailViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "ProfileManager.h"
#import "WhoHelpAppDelegate.h"

@implementation HelpDetailViewController

@synthesize loud=loud_;
@synthesize nameLabel=nameLabel_;
@synthesize locationLabel=locaitonLabel_;
@synthesize timeLabel=timeLabel_;
@synthesize avatarImage=avatarImage_;
@synthesize contentTextLabel=contentTextLabel_;
@synthesize distance=distance_;
@synthesize avatarData=avatarData_;
@synthesize sms=sms_;
@synthesize tel=tel_;

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
    
    self.avatarImage.image = [UIImage imageWithData:self.avatarData];
    self.avatarImage.opaque = YES;
    self.avatarImage.layer.borderWidth = 1.0;
    self.avatarImage.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;

    self.nameLabel.text = [[self.loud objectForKey:@"user"] objectForKey:@"name"];
    
    if ([[ProfileManager sharedInstance].profile.phone isEqualToNumber:
         [[self.loud objectForKey:@"user"] objectForKey:@"phone"]]){
        self.tel.enabled = NO;
        self.sms.enabled = NO;
    }
    
    self.contentTextLabel.attributedText = [Utils colorContent:[self.loud objectForKey:@"content"]];
    // get the geocoder address 
    if ([[self.loud objectForKey:@"address"] isEqual:[NSNull null]]){
        self.locationLabel.text = [self.loud objectForKey:@"distanceInfo"];
    }else{
        self.locationLabel.text = [NSString stringWithFormat:@"%@(%@)", [self.loud objectForKey:@"address"], [self.loud objectForKey:@"distanceInfo"]];
    }
    self.timeLabel.text = [Utils descriptionForTime:[self.loud objectForKey:@"createdTime"]];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - the tab bar operation

- (void)tabBar: (UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    switch (item.tag) {
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2:
        {
            // Go to case 3 handle.
        }
        case 3:
        {
            NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", item.tag == 2 ? @"tel" : @"sms", [[self.loud objectForKey:@"user"] objectForKey:@"phone"]]];
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


#pragma mark - dealloc
- (void)dealloc
{
    [locaitonLabel_ release];
    [loud_ release];
    [nameLabel_ release];
    [timeLabel_ release];
    [contentTextLabel_ release];
    [avatarImage_ release];
    [avatarData_ release];
    [tel_ release];
    [sms_ release];
    [super dealloc];
}

@end
