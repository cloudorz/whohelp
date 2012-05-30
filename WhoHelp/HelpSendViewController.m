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
#import "CustomItems.h"
#import <QuartzCore/QuartzCore.h>
#import "POIViewController.h"


@implementation HelpSendViewController

@synthesize helpTextView=_helpTextView;
@synthesize numIndicator=_numIndicator;
@synthesize loadingIndicator=_loadingIndicator;
@synthesize placeholderLabel=_placeholderLabel;
@synthesize myNavigationItem=_myNavigationItem;
@synthesize poi=_poi;
@synthesize address=_address;
@synthesize locaiton=_locaiton;

#pragma mark - dealloc
- (void)dealloc
{
    [_helpTextView release];
    [_numIndicator release];
    [_loadingIndicator release];
    [_placeholderLabel release];
    [_myNavigationItem release];
    [_poi release];
    [_address release];
    [_locaiton release];
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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
    
    // hidden char numberindicator
    self.numIndicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    
    // navigation item config
    self.myNavigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.myNavigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initSendBarButtonItemWithTarget:self 
                                              action:@selector(sendButtonPressed:)] autorelease];
    
    // init the weibo, renren, douban button enabled 
//    [self.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>]
 
    
}

-(void)backAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
    if (nonSpaceTextLength > 0){
        
        self.myNavigationItem.rightBarButtonItem.enabled = YES;
    } else{
        
        self.myNavigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)sendButtonPressed:(id)sender
{

    [self postHelpTextToRemoteServer];
    [self.loadingIndicator startAnimating];

}

- (void)postHelpTextToRemoteServer
{


    NSDictionary *preLoud = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"tag_content",
                             nil];
    // other params TODO
    
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

        [self dismissModalViewControllerAnimated:YES];
        
    } else{
        
        [self fadeOutMsgWithText:@"发送求助失败" rect:CGRectMake(0, 0, 80, 66)];
    }

    // send ok cancel
    [self.loadingIndicator stopAnimating];
    self.myNavigationItem.rightBarButtonItem.enabled = YES;
    

}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self.loadingIndicator stopAnimating];

    self.myNavigationItem.rightBarButtonItem.enabled = YES;
     
    //[Utils warningNotification:[[request error] localizedDescription]];
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
    if ([text isEqualToString:@"\n"]){

        [textView resignFirstResponder];
        
        // change the size
        CGRect numIndicatorFrame = self.numIndicator.frame;
        CGRect contentFrame = self.helpTextView.frame;
        
        numIndicatorFrame.origin.y = 163.0f;
        contentFrame.size.height = 172.0f;
        
        self.numIndicator.frame = numIndicatorFrame;
        self.helpTextView.frame = contentFrame;
        
        return NO;
    }
    
    if (textView.text.length + [text length] > 70){
        
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
-(IBAction)poiFindAction:(id)sender
{
    POIViewController *poivc = [[POIViewController alloc] initWithNibName:@"POIViewController" bundle:nil];
    [self presentModalViewController:poivc animated:YES];
    [poivc release];
}

-(IBAction)cancelAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
