//
//  HelpSendViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSendViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"
#import "ProfileManager.h"
#import "SelectDateViewController.h"
#import "SelectWardViewController.h"
#import "CustomItems.h"
#import "LocationController.h"
#import <QuartzCore/QuartzCore.h>


@implementation HelpSendViewController

@synthesize helpTextView=helpTextView_;
@synthesize numIndicator=numIndicator_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize placeholderLabel=placeholderLabel_;
@synthesize helpCategory=helpCategory_;
@synthesize avatar=avatar_;
@synthesize duetimeLabel=duetimeLabel_;
@synthesize wardLabel=wardLabel_;
@synthesize wardCategory=wardCategory_; 
@synthesize duetime=duetime_;
@synthesize duetimeButton=duetimeButton_;
@synthesize wardButton=wardButton_;
@synthesize wardText=wardText_;

#pragma mark - dealloc
- (void)dealloc
{
    [helpTextView_ release];
    [numIndicator_ release];
    [loadingIndicator_ release];
    [placeholderLabel_ release];
    [helpCategory_ release];
    [avatar_ release];
    [wardLabel_ release];
    [duetimeLabel_ release];
    [duetime_ release];
    [wardCategory_ release];
    [wardButton_ release];
    [duetimeButton_ release];
    [wardText_ release];
    [super dealloc];
}

#pragma mark - init with nib
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
    // display the keyboard
    // you might have to play around a little with numbers in CGRectMake method
    // they work fine with my settings
    self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12, 9, self.helpTextView.frame.size.width - 20.0, 16.0)] autorelease];
    self.placeholderLabel.text = @"请描述你的问题";
    
    // placeholderLabel is instance variable retained by view controller
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.font = [UIFont systemFontOfSize: 14.0];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    
    // textView is UITextView object you want add placeholder text to
    [self.helpTextView addSubview:self.placeholderLabel];
    
    [self.loadingIndicator stopAnimating];
    
    self.helpTextView.clipsToBounds = NO;
    [self.helpTextView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.helpTextView.layer setShadowRadius:0.7f];
    [self.helpTextView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.helpTextView.layer setShadowOpacity:0.25f];
    
    [self.helpTextView.layer setCornerRadius:5.0f];
    
    // label round and radius
    [self.duetimeLabel.layer setCornerRadius:5.0f];
    [self.wardLabel.layer setCornerRadius:5.0f];
    
    // hidden char numberindicator
    self.numIndicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    // new
    // custom navigation item
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:[self.helpCategory valueForKey:@"text"]] autorelease];
    
    self.avatar.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    
    // config buttons
    [self.duetimeButton setImage:[UIImage imageNamed:@"duetime.png"] forState:UIControlStateNormal];
    [self.duetimeButton setImage:[UIImage imageNamed:@"duetimedown.png"] forState:UIControlStateHighlighted];
    
    [self.wardButton setImage:[UIImage imageNamed:@"ward.png"] forState:UIControlStateNormal];
    [self.wardButton setImage:[UIImage imageNamed:@"warddown.png"] forState:UIControlStateHighlighted];
    
    // navigation item config
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initSendBarButtonItemWithTarget:self 
                                              action:@selector(sendButtonPressed:)] autorelease];
    
    // init the weibo, renren, douban button enabled 
    // TODO here
    
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
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
    
    // add event to detect the keyboard show.
    // so it can change the size of the text input.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    // show setting time
    if (nil != self.duetime){
        
        // config buttons
        [self.duetimeButton setImage:[UIImage imageNamed:@"duetimeon.png"] forState:UIControlStateNormal];
        [self.duetimeButton setImage:[UIImage imageNamed:@"duetimeondown.png"] forState:UIControlStateHighlighted];

    }
    
    // show setting ward
    if (nil != self.wardCategory){
        [self.wardButton setImage:[UIImage imageNamed:@"wardon.png"] forState:UIControlStateNormal];
        [self.wardButton setImage:[UIImage imageNamed:@"wardondown.png"] forState:UIControlStateHighlighted];
    }
    
    // send status
    [self turnOnSendEnabled];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self fakeParsePosition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.reverseGeocoder cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//#pragma mark - set value for other view controller
//-(void)duetimeSetAction:(id)sender
//{
//    self.duetime = 
//}

- (void)turnOnSendEnabled
{
    // check the send button enabled 
     NSInteger nonSpaceTextLength = [[self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if (self.helpCategory != nil && 
        self.wardCategory != nil &&
        nonSpaceTextLength > 0 &&
        self.duetime != nil){
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)sendButtonPressed:(id)sender
{
    [self fakePostHelpTextToRemoteServer];
    [self.loadingIndicator startAnimating];
    //[self fakeParsePosition];
}

- (void)fakePostHelpTextToRemoteServer
{
    if ([CLLocationManager locationServicesEnabled]){
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        //    self.sendBarItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self performSelector:@selector(postHelpTextToRemoteServer) withObject:nil afterDelay:3.0];
    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    }       
}

- (void)postHelpTextToRemoteServer
{
    
    if (NO == [LocationController sharedInstance].allow){
        [Utils tellNotification:@"乐帮需要获取你位置信息的许可，以便提供帮助的人查看你的求助地点。"];
        return;
    }
    
    [self.loadingIndicator startAnimating];
    
    // make json data for post
    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];


    NSDictionary *preLoud = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:curloc.latitude], @"lat",
                             [NSNumber numberWithDouble:curloc.longitude], @"lon",
                             [self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"content",
                             [self.wardCategory objectForKey:@"label"], @"paycate",
                             [self.helpCategory objectForKey:@"label"], @"loudcate",
                             self.duetime, @"expired",
                             self.wardText, @"paydesc", // This is a tricker, wardText is nil, the dictionary cut down.
                             nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, LOUDURI]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[preLoud JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"POST"];
    // sign to header for authorize
    [request signInHeader];
    [request setDelegate:self];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    if ([request responseStatusCode] == 201){

        [self.navigationController popViewControllerAnimated:YES];
        
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"非正常返回"];
    }

    // send ok cancel
    [self.loadingIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self.loadingIndicator stopAnimating];

    self.navigationItem.rightBarButtonItem.enabled = YES;
    // 
    [Utils warningNotification:[[request error] localizedDescription]];

}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"done the editing change");
    if(![textView hasText]) {
        
        [textView addSubview:self.placeholderLabel];
        self.numIndicator.hidden = YES;
        
    } else if ([[textView subviews] containsObject:self.placeholderLabel]) {
        
        [self.placeholderLabel removeFromSuperview];
        self.numIndicator.hidden = NO;
        
    }
        
    //NSInteger nonSpaceTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    self.numIndicator.text = [NSString stringWithFormat:@"%d", 70 - /*nonSpaceTextLength*/[self.helpTextView.text length]];
    
    [self turnOnSendEnabled];

}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![theTextView hasText]) {
        [theTextView addSubview:self.placeholderLabel];
        self.numIndicator.hidden = YES;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //NSInteger inputedTextLength = [textView.text length];
    if ([text isEqualToString:@"\n"] || textView.text.length + [text length] > 70){
        return NO;
    } 
    
    return YES;
}

#pragma mark - dimiss the keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.helpTextView resignFirstResponder];
    
    // change the size
    CGRect numIndicatorFrame = self.numIndicator.frame;
    CGRect contentFrame = self.helpTextView.frame;
    
    numIndicatorFrame.origin.y = 163.0f;
    contentFrame.size.height = 172.0f;
    
    self.numIndicator.frame = numIndicatorFrame;
    self.helpTextView.frame = contentFrame;
}


# pragma mark - keyboard show event for resize the UI
- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    NSValue *endingFrame = [[notif userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame;
    [endingFrame getValue:&frame];
    
    CGRect numIndicatorFrame = self.numIndicator.frame;
    CGRect contentFrame = self.helpTextView.frame;
    
    numIndicatorFrame.origin.y = 411.0f - (frame.size.height + 32.0f);
    contentFrame.size.height = 411.0f - (frame.size.height + 23.0f);
    
    self.numIndicator.frame = numIndicatorFrame;
    self.helpTextView.frame = contentFrame;
    
}

#pragma mark - actions

- (IBAction)duetimeAction:(id)sender
{
    SelectDateViewController *sdVC = [[SelectDateViewController alloc] initWithNibName:@"SelectDateViewController" bundle:nil];
    sdVC.hlVC = self;
    [self.navigationController pushViewController:sdVC animated:YES];
    [sdVC release];
}

- (IBAction)wadAction:(id)sender
{
    SelectWardViewController *swVC = [[SelectWardViewController alloc] initWithNibName:@"SelectWardViewController" bundle:nil];
    swVC.hlVC = self;
    [self.navigationController pushViewController:swVC animated:YES];
    [swVC release];
}

- (IBAction)renrenAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (hasRenren){
        hasRenren = NO;
        // do some thing here
        [button setImage:[UIImage imageNamed:@"renrenx.png"] forState:UIControlStateNormal];
    } else{
        hasRenren = YES;
        [button setImage:[UIImage imageNamed:@"renreno.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)weiboAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (hasWeibo){
        hasWeibo = NO;
        // do some thing here
        [button setImage:[UIImage imageNamed:@"weibox.png"] forState:UIControlStateNormal];
    } else{
        hasWeibo = YES;
        [button setImage:[UIImage imageNamed:@"weiboo.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)doubanAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (hasDouban){
        hasDouban = NO;
        // do some thing here
        [button setImage:[UIImage imageNamed:@"doubanx.png"] forState:UIControlStateNormal];
    } else{
        hasDouban = YES;
        [button setImage:[UIImage imageNamed:@"doubano.png"] forState:UIControlStateNormal];
    }
}

@end
