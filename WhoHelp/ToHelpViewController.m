//
//  ToHelpViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ToHelpViewController.h"
#import "ProfileManager.h"
#import "CustomItems.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "LocationController.h"
#import "Utils.h"
#import "Config.h"
#import "SBJson.h"

@implementation ToHelpViewController

@synthesize loud=loud_;
@synthesize isHelp=isHelp_;
@synthesize avatarImage=avatarImage_;
@synthesize phoneShow=phoneShow_;
@synthesize content=content_;
@synthesize numIndicator=numIndicator_;
@synthesize placeholderLabel=placeholderLabel_;
@synthesize phoneImage=phoneImage_;

-(void)dealloc
{
    [loud_ release];
    [content_ release];
    [phoneShow_ release];
    [avatarImage_ release];
    [numIndicator_ release];
    [placeholderLabel_ release];
    [phoneImage_ release];
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
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                               initSendBarButtonItemWithTarget:self 
                                               action:@selector(sendButtonPressed:)] autorelease];
    
    self.navigationItem.titleView = [[[NavTitleLabel alloc] 
                                       initWithTitle:self.isHelp ? @"我来帮助" : @"我来围观"] autorelease];
    
    // 

    self.avatarImage.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    if (self.isHelp) {
        self.phoneShow.hidden = NO;
        
        if ([ProfileManager sharedInstance].profile.phone == nil){
            self.phoneImage.image = [UIImage imageNamed:@"nophone.png"];
        }
    }
    // content text view
    [self.content becomeFirstResponder];
    
    self.content.clipsToBounds = NO;
    [self.content.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.content.layer setShadowRadius:0.7f];
    [self.content.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.content.layer setShadowOpacity:0.25f];
    
    [self.content.layer setCornerRadius:5.0f];
    
    // they work fine with my settings
    self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12, 9, self.content.frame.size.width - 20.0, 16.0)] autorelease];
    self.placeholderLabel.text = @"请输入你的内容";
    
    // placeholderLabel is instance variable retained by view controller
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.font = [UIFont systemFontOfSize: 14.0];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    
    // textView is UITextView object you want add placeholder text to
    [self.content addSubview:self.placeholderLabel];
    
    // hidden char numberindicator
    self.numIndicator.hidden = YES;
    
    // unabel the send button
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // add event to detect the keyboard show.
    // so it can change the size of the text input.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonPressed:(id)sender
{
    [self fakeSendPost];
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

# pragma mark - keyboard show event for resize the UI
- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    NSValue *endingFrame = [[notif userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame;
    [endingFrame getValue:&frame];
    
    CGRect numIndicatorFrame = self.numIndicator.frame;
    CGRect contentFrame = self.content.frame;
    
    numIndicatorFrame.origin.y = 411.0f - (frame.size.height + 30.0f);
    contentFrame.size.height = 411.0f - (frame.size.height + 23.0f);
    
    self.numIndicator.frame = numIndicatorFrame;
    self.content.frame = contentFrame;
    
}

-(void)turnOnSendEnabled
{
    if ([self.content hasText] && self.isHelp ? [ProfileManager sharedInstance].profile.phone != nil : YES){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - send post
- (void)fakeSendPost
{
    if ([CLLocationManager locationServicesEnabled]){
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self performSelector:@selector(sendPost) withObject:nil afterDelay:3.0];
    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    }       
}

- (void)sendPost
{
    
    if (NO == [LocationController sharedInstance].allow){
        [Utils tellNotification:@"乐帮需要获取你位置信息的许可，以便提供帮助的人查看你的求助地点。"];
        return;
    }
    
    //[self.loadingIndicator startAnimating];
    
    // make json data for post
    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
    
    
    NSDictionary *prePost = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:curloc.latitude], @"lat",
                             [NSNumber numberWithDouble:curloc.longitude], @"lon",
                             [NSNumber numberWithBool: self.isHelp], @"is_help",
                             [self.loud objectForKey:@"id"], @"urn",
                             [self.content.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"content",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, REPLYURI]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[prePost JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
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
    //[self.loadingIndicator stopAnimating];

    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    //[self.loadingIndicator stopAnimating];
    
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
    
    NSInteger nonSpaceTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    self.numIndicator.text = [NSString stringWithFormat:@"%d", 70 - nonSpaceTextLength/*[self.helpTextView.text length]*/];
    
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
    NSInteger inputedTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if ([text isEqualToString:@"\n"] || inputedTextLength + [text length] > 70){
        return NO;
    } 

    return YES;
}

@end
