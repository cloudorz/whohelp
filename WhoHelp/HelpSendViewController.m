//
//  HelpSendViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSendViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Utils.h"
#import "ProfileManager.h"
#import "SelectDateViewController.h"
#import "SelectWardViewController.h"


@implementation HelpSendViewController

@synthesize helpTextView=helpTextView_;
@synthesize numIndicator=numIndicator_;
@synthesize sendBarItem=sendBarItem_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize placeholderLabel=placeholderLabel_;

// new 
@synthesize helpCategory=helpCategory_;
@synthesize avatar=avatar_;
@synthesize duetimeLabel=duetimeLabel_;
@synthesize wardLabel=wardLabel_;

#pragma mark - dealloc
- (void)dealloc
{
    [helpTextView_ release];
    [numIndicator_ release];
    [sendBarItem_ release];
    [loadingIndicator_ release];
    [placeholderLabel_ release];
    // new
    [helpCategory_ release];
    [avatar_ release];
    [wardLabel_ release];
    [duetimeLabel_ release];
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
    self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(8, 2.5, self.helpTextView.frame.size.width - 20.0, 34.0)] autorelease];
    self.placeholderLabel.text = @"描述一下你的问题";

    // placeholderLabel is instance variable retained by view controller
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.font = [UIFont systemFontOfSize: 14.0];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    
    // textView is UITextView object you want add placeholder text to
    [self.helpTextView addSubview:self.placeholderLabel];
    
    // show keyboard
//    [self.helpTextView becomeFirstResponder];
    [self.loadingIndicator stopAnimating];
    
    // hidden char numberindicator
    self.numIndicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    // new
    self.navigationItem.title = [self.helpCategory valueForKey:@"text"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.action = @selector(sendButtonPressed:);
    self.avatar.image = [UIImage imageNamed:@"avatar.png"];  
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

#pragma mark - modal actions
-(IBAction)cancelButtonPressed:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction)sendButtonPressed:(id)sender
{
    [self fakePostHelpTextToRemoteServer];
    [self.loadingIndicator startAnimating];
    //[self fakeParsePosition];
}

- (void)fakePostHelpTextToRemoteServer
{
    if ([CLLocationManager locationServicesEnabled]){
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        [self performSelector:@selector(postHelpTextToRemoteServer) withObject:nil afterDelay:3.0];
    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    }       
}

- (void)postHelpTextToRemoteServer
{
    
//    if (NO == [LocationController sharedInstance].allow){
//        [Utils tellNotification:@"乐帮需要获取你位置信息的许可，以便提供帮助的人查看你的求助地点。"];
//        return;
//    }
//    
//    [self.loadingIndicator startAnimating];
//    self.sendBarItem.enabled = NO;
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?tk=%@&ak=%@", SENDURI, [ProfileManager sharedInstance].profile.token, APPKEY]];
//    
//    // make json data for post
//    CLLocationCoordinate2D curloc = [LocationController sharedInstance].location.coordinate;
//    [[LocationController sharedInstance].locationManager stopUpdatingLocation];
//
//    NSMutableDictionary *preLoud = [[NSMutableDictionary alloc] init];
//    [preLoud setObject:[NSNumber numberWithDouble:curloc.latitude] forKey:@"lat"];
//    [preLoud setObject:[NSNumber numberWithDouble:curloc.longitude] forKey:@"lon"];
//    [preLoud setObject:[self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"content"];
//    
//    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
//    NSString *dataString = [preJson stringWithObject:preLoud];
//    [preJson release];
//    [preLoud release];
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
//    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
//    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
//    [request setRequestMethod:@"POST"];
//    [request setDelegate:self];
//    
//    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    if ([request responseStatusCode] == 201){
        [self dismissModalViewControllerAnimated:YES];
        
    } else if (412 == [request responseStatusCode]){
        [Utils warningNotification:@"每个用户最多可发三条求助信息，请先删除部分求助再发送"];
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"非正常返回"];
    }

    // send ok cancel
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self.loadingIndicator stopAnimating];
    self.sendBarItem.enabled = YES;
    // 
    [Utils warningNotification:[[request error] localizedDescription]];

}

- (IBAction)addRewardButtonPressed:(id)sender
{
    self.helpTextView.text = [NSString stringWithFormat:@"%@%@", self.helpTextView.text, @"$"];
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
    
    if (nonSpaceTextLength <= 0) {
        self.sendBarItem.enabled = NO;
    } else{
        self.sendBarItem.enabled = YES;
    }

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
    if ([text isEqualToString:@"\n"]){
        return NO;
    }
    
    return YES;
}

#pragma mark - dimiss the keyboard
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    [textView resignFirstResponder];
//    NSLog(@"fufufufufuck");
//    return YES;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.helpTextView resignFirstResponder];
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

    if (frame.size.height == 480.0f){
        // FIXME maybe work?
        numIndicatorFrame.origin.y = 320.0f - 44.0f - (frame.size.width + 50.0f);
        contentFrame.size.height = 320.0f - 44.0f - (frame.size.width + 50.0f);

    } else {
        
        numIndicatorFrame.origin.y = 480.0f - 44.0f - (frame.size.height + 51.0f);
        contentFrame.size.height = 480.0f - 44.0f - (frame.size.height + 48.0f);
    }
    
    self.numIndicator.frame = numIndicatorFrame;

    self.helpTextView.frame = contentFrame;

}

#pragma mark - actions

- (IBAction)duetimeAction:(id)sender
{
    SelectDateViewController *sdVC = [[SelectDateViewController alloc] initWithNibName:@"SelectDateViewController" bundle:nil];
    [self.navigationController pushViewController:sdVC animated:YES];
    [sdVC release];
}

- (IBAction)wadAction:(id)sender
{
    SelectWardViewController *swVC = [[SelectWardViewController alloc] initWithNibName:@"SelectWardViewController" bundle:nil];
    [self.navigationController pushViewController:swVC animated:YES];
    [swVC release];
}

- (IBAction)renrenAction:(id)sender
{
}

- (IBAction)weiboAction:(id)sender
{
}

- (IBAction)doubanAction:(id)sender
{
}

#pragma mark - get the address from lat and lon
- (void)fakeParsePosition
{
    if ([CLLocationManager locationServicesEnabled]){
        self.sendBarItem.enabled = NO;
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        [self performSelector:@selector(parsePosition) withObject:nil afterDelay:2.0];
    } else{
        [Utils tellNotification:@"请开启定位服务，乐帮需获取地理位置为你服务。"];
    } 
    
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

@end
