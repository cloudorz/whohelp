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
@synthesize distance=distance_;

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
    if (nil == self.loud.address){
        self.locationLabel.text = [NSString stringWithFormat:@"%.0f米", self.distance];
    }else{
        self.locationLabel.text = [NSString stringWithFormat:@"%@(%.0f米)", self.loud.address, self.distance];
    }
    self.timeLabel.text = [self descriptionForTime:self.loud.created];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSString *)descriptionForTime:(NSDate *)date
{
    // convert the time formate to human reading. 
    // FIXME 24hours maybe two days.
    NSInteger timePassed = abs([date timeIntervalSinceNow]);
    
    NSString *dateString = nil;
    if (timePassed < 60){
        dateString = [NSString stringWithFormat:@"%d秒前", timePassed];
    }else{
        if (timePassed < 60*60){
            dateString = [NSString stringWithFormat:@"%d分前", timePassed/60];
        }else{
            NSDateFormatter *dateFormat = [NSDateFormatter alloc];
            [dateFormat setLocale:[NSLocale currentLocale]];
            NSString *dateFormatString = nil;
            
            if (timePassed < 24*60*60){
                dateFormatString = [NSString stringWithFormat:@"今天 %@", [NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]]];
            }else{
                dateFormatString = [NSDateFormatter dateFormatFromTemplate:@"MM-dd HH:mm" options:0 locale:[NSLocale currentLocale]];
            }
            [dateFormat setDateFormat:dateFormatString];
            dateString = [dateFormat stringFromDate:date];
        }
    }
    return dateString;
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
