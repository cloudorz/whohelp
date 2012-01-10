//
//  PrizeHelperViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PrizeHelperViewController.h"
#import "SelectUserViewController.h"
#import "CustomItems.h"
#import "ProfileManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "Config.h"
#import "SBJson.h"
#import "Utils.h"
#import "UserManager.h"

@implementation PrizeHelperViewController

@synthesize loud=loud_;
@synthesize avatar=avatar_;
@synthesize hasStar=hasStar_;
@synthesize selectUserButton=selectUserButton_;
@synthesize turnStarButton=turnStarButton_;
@synthesize content=content_;
@synthesize numIndicator=numIndicator_;
@synthesize placeholderLabel=placeholderLabel_;
@synthesize toUser=toUser_;

-(void)dealloc
{
    [loud_ release];
    [selectUserButton_ release];
    [turnStarButton_ release];
    [avatar_ release];
    [numIndicator_ release];
    [placeholderLabel_ release];
    [content_ release];
    [toUser_ release];
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
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"感谢信"] autorelease];
    
    self.hasStar = NO;
    
    self.avatar.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    
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
    self.placeholderLabel.text = @"我想感谢TA";
    
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // add event to detect the keyboard show.
    // so it can change the size of the text input.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    
    if (self.toUser != nil){
        [[UserManager sharedInstance] fetchPhotoRequestWithLink:self.toUser forBlock:^(NSData *data){
            [self.selectUserButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}


#pragma mark - actions

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonPressed:(id)sender
{
    [self sendPrizePost];
}

-(IBAction)turnStarAction:(id)sender
{
    if (self.hasStar){
        self.hasStar = NO;
        // do some thing here
        [self.turnStarButton setImage:[UIImage imageNamed:@"stardown.png"] forState:UIControlStateNormal];
    } else{
        self.hasStar = YES;
        [self.turnStarButton setImage:[UIImage imageNamed:@"starup.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)selectUserAction:(id)sender
{
    SelectUserViewController *suvc = [[SelectUserViewController alloc] initWithNibName:@"SelectUserViewController" bundle:nil];
    suvc.loudURN = [self.loud objectForKey:@"id"];
    suvc.phvc = self;
    [self.navigationController pushViewController:suvc animated:YES];
    [suvc release];
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
    if (nonSpaceTextLength > 0 && self.toUser != nil){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)sendPrizePost
{

    //[self.loadingIndicator startAnimating];
    
    NSDictionary *prePost = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool: self.hasStar], @"has_star",
                             [self.loud objectForKey:@"id"], @"loud_urn",
                             [self.toUser objectForKey:@"id"], @"user_urn",
                             [self.content.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"content",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, PRIZEURI]];
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
