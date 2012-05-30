//
//  ProfileViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "CustomItems.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileViewController

@synthesize user=_user;
@synthesize toHelpIndicator=_toHelpIndicator;
@synthesize beHelpedIndicator=_beHelpedIndicator;
@synthesize starIndicator=_starIndicator;
@synthesize toHelpView=_toHelpView;
@synthesize beHelpedView=_beHelpedView;
@synthesize starView=_starView;
@synthesize nameLabel=_nameLabel;
@synthesize descLabel=_descLabel;
@synthesize avatarImage=_avatarImage;
@synthesize descView=_descView;
@synthesize userLink=_userLink;


-(void)dealloc
{
    [_user release];
    [_toHelpIndicator release];
    [_beHelpedView release];
    [_beHelpedIndicator release];
    [_toHelpView release];
    [_starView release];
    [_descLabel release];
    [_starIndicator release];
    [_descView release];
    [_nameLabel release];
    [_avatarImage release];
    [_userLink release];
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

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.titleView = [[[NavTitleLabel alloc] 
                                      initWithTitle:@"个人信息"] autorelease];
    
    
    self.descView.clipsToBounds = NO;
    [self.descView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.descView.layer setShadowRadius:0.7f];
    [self.descView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.descView.layer setShadowOpacity:0.25f];
    [self.descView.layer setCornerRadius:5.0f];
    
    self.starView.clipsToBounds = NO;
    [self.starView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.starView.layer setShadowRadius:0.7f];
    [self.starView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.starView.layer setShadowOpacity:0.25f];
    [self.starView.layer setCornerRadius:5.0f];
    
    self.beHelpedView.clipsToBounds = NO;
    [self.beHelpedView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.beHelpedView.layer setShadowRadius:0.7f];
    [self.beHelpedView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.beHelpedView.layer setShadowOpacity:0.25f];
    [self.beHelpedView.layer setCornerRadius:5.0f];
    
    self.toHelpView.clipsToBounds = NO;
    [self.toHelpView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.toHelpView.layer setShadowRadius:0.7f];
    [self.toHelpView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.toHelpView.layer setShadowOpacity:0.25f];
    [self.toHelpView.layer setCornerRadius:5.0f];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self grapUserDetail];
    // config

    [self.avatarImage loadImage:[self.user objectForKey:@"avatar_link"]];

    // maybe leak happen
    self.nameLabel.text = [self.user objectForKey:@"name"];
    self.toHelpIndicator.text = [[self.user objectForKey:@"help_num"] description];
    self.beHelpedIndicator.text = [[self.user objectForKey:@"loud_num"] description];
    self.starIndicator.text = [[self.user objectForKey:@"star_num"] description];
    
    NSString *brief = [self.user objectForKey:@"brief"] != [NSNull null] ? [self.user objectForKey:@"brief"] : nil;
    // brief show
    if (brief != nil && brief.length > 0){
        CGSize theSize= [[self.user objectForKey:@"brief"] sizeWithFont:[UIFont systemFontOfSize:12.0f] 
                                                      constrainedToSize:CGSizeMake(272.0, CGFLOAT_MAX) 
                                                          lineBreakMode:UILineBreakModeWordWrap];
        CGFloat contentHeight = theSize.height;
        CGRect descLabelFrame = self.descLabel.frame;
        descLabelFrame.size.height += contentHeight - 12.0f;
        self.descLabel.frame = descLabelFrame;
        
        self.descLabel.text = [self.user objectForKey:@"brief"];
    }

}

- (void)grapUserDetail
{
    NSURL *url = [NSURL URLWithString:self.userLink];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200) {
            NSString *response = [request responseString];
            self.user = [response JSONValue];
        }
        
    }
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
