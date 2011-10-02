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

@implementation HelpDetailViewController

@synthesize loud=loud_;
@synthesize nameLabel=nameLabel_;
@synthesize locationLabel=locaitonLabel_;
@synthesize timeLabel=timeLabel_;
@synthesize avatarImage=avatarImage_;
@synthesize contentTextLabel=contentTextLabel_;
@synthesize distance=distance_;
@synthesize avatarData=avatarData_;

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
    

    //if ([[self.loud objectForKey:@"user"] objectForKey:@"avatarData"] != nil){
        self.avatarImage.image = [UIImage imageWithData:self.avatarData];
        self.avatarImage.opaque = YES;
        self.avatarImage.layer.borderWidth = 1.0;
        self.avatarImage.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    //}
    self.nameLabel.text = [[self.loud objectForKey:@"user"] objectForKey:@"name"];
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:[self.loud objectForKey:@"content"]];
    [attributedString setFont:[UIFont systemFontOfSize:14.0]];
    [attributedString setTextColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0]];
    
    NSRange rang = [[self.loud objectForKey:@"content"] rangeOfString:@"$" options:NSBackwardsSearch];
    if (NSNotFound != rang.location){
        [attributedString setTextColor:[UIColor colorWithRed:111/255.0 green:195/255.0 blue:58/255.0 alpha:1.0] range:NSMakeRange(rang.location, [[self.loud objectForKey:@"content"] length] - rang.location)];
    }
    self.contentTextLabel.attributedText = attributedString;
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
    [super dealloc];
}

@end
