//
//  ProfileViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "CustomItems.h"
#import <QuartzCore/QuartzCore.h>
#import "UserManager.h"

@implementation ProfileViewController

@synthesize user=user_;
@synthesize toHelpIndicator=toHelpIndicator_;
@synthesize beHelpedIndicator=beHelpedIndicator_;
@synthesize starIndicator=starIndicator_;
@synthesize toHelpView=toHelpView_;
@synthesize beHelpedView=beHelpedView_;
@synthesize starView=starView_;
@synthesize nameLabel=nameLabel_;
@synthesize descLabel=descLabel_;
@synthesize avatarImage=avatarImage_;
@synthesize descView=descView_;


-(void)dealloc
{
    [user_ release];
    [toHelpIndicator_ release];
    [beHelpedIndicator_ release];
    [starIndicator_ release];
    [toHelpView_ release];
    [beHelpedView_ release];
    [starView_ release];
    [descLabel_ release];
    [descView_ release];
    [nameLabel_ release];
    [avatarImage_ release];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // config

    [[UserManager sharedInstance] fetchPhotoRequestWithLink:self.user forBlock:^(NSData *data){
        if (data != nil){
            self.avatarImage.image = [UIImage imageWithData:data];
        }
    }];
    
    // maybe leak happen
    [[UserManager sharedInstance] fetchUserRequestWithLink:self.user forBlock:^(NSDictionary *data){
        self.nameLabel.text = [data objectForKey:@"name"];
        self.toHelpIndicator.text = [[data objectForKey:@"to_help_num"] description];
        self.beHelpedIndicator.text = [[data objectForKey:@"be_helped_num"] description];
        self.starIndicator.text = [[data objectForKey:@"star_num"] description];
        
        NSString *brief = [data objectForKey:@"brief"] != [NSNull null] ? [data objectForKey:@"brief"] : nil;
        // brief show
        if (brief != nil && brief.length > 0){
            CGSize theSize= [[data objectForKey:@"brief"] sizeWithFont:[UIFont systemFontOfSize:12.0f] 
                                                          constrainedToSize:CGSizeMake(272.0, CGFLOAT_MAX) 
                                                              lineBreakMode:UILineBreakModeWordWrap];
            CGFloat contentHeight = theSize.height;
            CGRect descLabelFrame = self.descLabel.frame;
            descLabelFrame.size.height += contentHeight - 12.0f;
            self.descLabel.frame = descLabelFrame;
            
            self.descLabel.text = [data objectForKey:@"brief"];
        } 
    }];
    

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
