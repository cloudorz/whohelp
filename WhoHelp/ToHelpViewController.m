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
#import "DDAlertPrompt.h"

@implementation ToHelpViewController

@synthesize loud=loud_;
@synthesize isHelp=isHelp_;
@synthesize avatarImage=avatarImage_;
@synthesize phoneShow=phoneShow_;
@synthesize content=content_;
@synthesize numIndicator=numIndicator_;
@synthesize placeholderLabel=placeholderLabel_;
@synthesize toUser=toUser_;
@synthesize phoneButton=phoneButton_;
@synthesize isOwner;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize tmpPhoneNum=tmpPhoneNum_;

-(void)dealloc
{
    [loud_ release];
    [content_ release];
    [phoneShow_ release];
    [avatarImage_ release];
    [numIndicator_ release];
    [placeholderLabel_ release];
    [toUser_ release];
    [phoneButton_ release];
    [loadingIndicator_ release];
    [tmpPhoneNum_ release];
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
    
    self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                               initSendBarButtonItemWithTarget:self 
                                               action:@selector(sendButtonPressed:)] autorelease];
    NSString *titleString = nil;
    if (self.isOwner || self.toUser != nil){
        titleString = @"回复";
    } else if (self.isHelp){
        titleString = @"我来帮助";
    } else{
        titleString = @"我来围观";
    }
    
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:titleString] autorelease];

    self.avatarImage.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    if (!self.isOwner) {
        self.phoneShow.hidden = NO;
        
        if (self.isHelp && [ProfileManager sharedInstance].profile.phone != nil){
            [self.phoneButton setImage:[UIImage imageNamed:@"havephone.png"] forState:UIControlStateNormal];
        } else{
            self.isHelp = NO;
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
    
    [self.loadingIndicator stopAnimating];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // add event to detect the keyboard show.
    // so it can change the size of the text input.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    // to user will be display it
    if (self.toUser != nil){
         NSString *preContent = [NSString stringWithFormat:@"@%@ ", [self.toUser objectForKey:@"name"]];
        self.content.text = preContent;
        [self.placeholderLabel removeFromSuperview];
    }
   
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
    [self.loadingIndicator startAnimating];
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
    
    numIndicatorFrame.origin.y = 411.0f - (frame.size.height + 32.0f);
    contentFrame.size.height = 411.0f - (frame.size.height + 23.0f);
    
    self.numIndicator.frame = numIndicatorFrame;
    self.content.frame = contentFrame;
    
}

-(void)turnOnSendEnabled
{
    NSInteger nonSpaceTextLength = [[self.content.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if (nonSpaceTextLength > 0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(IBAction)turnPhoneAction:(id)sender
{
    if (self.isHelp){
        self.isHelp = NO;
        [self.phoneButton setImage:[UIImage imageNamed:@"nophone.png"] forState:UIControlStateNormal];
    } else{
        if ([ProfileManager sharedInstance].profile.phone == nil){
//            [Utils warningNotification:@"在关于我中设置你的号码"];
            DDAlertPrompt *loginPrompt = [[DDAlertPrompt alloc] initWithTitle:nil 
                                                                     delegate:self 
                                                            cancelButtonTitle:@"取消" 
                                                             otherButtonTitle:@"确定"];	
            [loginPrompt show];
            [loginPrompt release];
            
        } else{
            self.isHelp = YES;
            [self.phoneButton setImage:[UIImage imageNamed:@"havephone.png"] forState:UIControlStateNormal]; 
        }

    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
		DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
		[loginPrompt.plainTextField becomeFirstResponder];		
		[loginPrompt setNeedsLayout];
	}
}

- (void)updateUserInfo
{
    
    NSDictionary *preInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.tmpPhoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"phone",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[ProfileManager sharedInstance].profile.link];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[preInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"PUT"];
    // sign to header for authorize

    [request setDelegate:self];
    [request setDidFinishSelector:@selector(pRequestFinished:)];
    [request setDidFailSelector:@selector(pRequestFailed:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)pRequestFinished:(ASIHTTPRequest *)request
{
    
    if ([request responseStatusCode] == 200){
        
        // update profile
        [ProfileManager sharedInstance].profile.phone = self.tmpPhoneNum;
        self.isHelp = YES;
        [self.phoneButton setImage:[UIImage imageNamed:@"havephone.png"] forState:UIControlStateNormal];
        
    } else{
        
        [Utils warningNotification:@"设置失败"];
    }
    
    
}

- (void)pRequestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

-(BOOL)testPhoneNumber:(NSString *)num
{
    NSString *decimalRegex = @"^([0-9]{11})|(([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1})|([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1}))$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    return [decimalTest evaluateWithObject:num];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
	} else {
		if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
			DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
            if (![loginPrompt.plainTextField.text isEqualToString:@""] && ![self testPhoneNumber:loginPrompt.plainTextField.text]) {
                
                [Utils warningNotification:@"无效号码"];
                
            } else{
                self.tmpPhoneNum = loginPrompt.plainTextField.text;
                [self updateUserInfo];
            }
			
		}
	}
}

#pragma mark - send post
- (void)fakeSendPost
{
    if ([CLLocationManager locationServicesEnabled]){
        [[LocationController sharedInstance].locationManager startUpdatingLocation];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self performSelector:@selector(sendPost) withObject:nil afterDelay:1.5];
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
    NSInteger code = [request responseStatusCode];
    if (201 == code){

        [self.navigationController popViewControllerAnimated:YES];
        
    } else if (412 == code) {
        
        NSString *body = [request responseString];
        NSDictionary *reason = [body JSONValue];
        [self.loud setValuesForKeysWithDictionary:reason];        
        
        // notification
        int statusCode = [[reason objectForKey:@"status"] intValue];
        if (300 == statusCode){

            [self fadeOutMsgWithText:@"求助已完成" rect:CGRectMake(0, 0, 80, 66)];
        } else if (100 == statusCode){

            [self fadeOutMsgWithText:@"求助已过期" rect:CGRectMake(0, 0, 80, 66)];
        }
        
    } else if (404 == code) {
        
        [self.loud setObject:[NSNumber numberWithInt:-100] forKey:@"status"];
        
        [self fadeOutMsgWithText:@"求助已删除" rect:CGRectMake(0, 0, 80, 66)];
        
    } else{
        
       [self fadeOutMsgWithText:@"发送失败" rect:CGRectMake(0, 0, 80, 66)];
        
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

    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
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
    self.numIndicator.text = [NSString stringWithFormat:@"%d", 70 - /*nonSpaceTextLength*/[self.content.text length]];
    
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
    //NSInteger inputedTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if ([text isEqualToString:@"\n"] || self.content.text.length + [text length] > 70){
        return NO;
    } 

    return YES;
}

@end
