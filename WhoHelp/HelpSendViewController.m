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
#import "Utils.h"
#import "ProfileManager.h"
#import "CustomItems.h"
//#import <QuartzCore/QuartzCore.h>
#import "POIViewController.h"


@implementation HelpSendViewController

@synthesize helpTextView=_helpTextView;
@synthesize numIndicator=_numIndicator;
@synthesize loadingIndicator=_loadingIndicator;
@synthesize placeholderLabel=_placeholderLabel;
@synthesize poi=_poi;
@synthesize address=_address;
@synthesize locaiton=_locaiton;
@synthesize helpCategory=_helpCategory;
@synthesize uv=_uv;
@synthesize ann=_ann;
@synthesize poiLabel=_poiLabel;

#pragma mark - dealloc
- (void)dealloc
{
    [_helpTextView release];
    [_numIndicator release];
    [_loadingIndicator release];
    [_placeholderLabel release];
    [_poi release];
    [_address release];
    [_locaiton release];
    [_helpCategory release];
    [_uv release];
    [_ann release];
    [_poiLabel release];
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
    
    [self.loadingIndicator stopAnimating];
    
    // hidden char numberindicator
    self.numIndicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    
    // navigation item config
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initSendBarButtonItemWithTarget:self 
                                              action:@selector(sendButtonPressed:)] autorelease];
    
    // init the weibo, renren, douban button enabled 
    hasWeibo = NO;
    
    // custom navigation item
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:[self.helpCategory valueForKey:@"text"]] autorelease];
    
    self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 7, 120, 20)] autorelease];
    self.placeholderLabel.font = [UIFont systemFontOfSize:16.0];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.text = @"描述你的问题";
    
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
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
//    [self turnOnSendEnabled];
    [self.helpTextView becomeFirstResponder];
    [self textViewDidChange:self.helpTextView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self fakeParsePosition];
//    self.helpTextView.text = [NSString stringWithFormat:@"#%@#", [self.helpCategory valueForKey:@"text"]];
    if (self.ann != nil) {
        self.poiLabel.text = self.ann.title;
    }
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
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)sendButtonPressed:(id)sender
{

    [self postHelpTextToRemoteServer];
    [self.loadingIndicator startAnimating];

}

- (void)postHelpTextToRemoteServer
{

    NSArray *locaction = [NSArray arrayWithObjects: [NSNumber numberWithFloat:self.ann.coordinate.longitude], 
                          [NSNumber numberWithFloat:self.ann.coordinate.latitude], nil];

    NSDictionary *preLoud = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.helpTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"tag_content",
                             [self.helpCategory objectForKey:@"label"], @"category",
                             self.ann.title, @"poi",
                             self.ann.subtitle, @"address",
                             locaction, @"location",
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

        [self.navigationController popViewControllerAnimated:YES];
        
    } else{
        
        [self fadeOutMsgWithText:@"发送求助失败" rect:CGRectMake(0, 0, 90, 60) offSetY:120];

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
     
    //[Utils warningNotification:[[request error] localizedDescription]];
     [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 60) offSetY:120];

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

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"done the editing change");
    if(![textView hasText]) {
        
        [textView addSubview:self.placeholderLabel];
        self.numIndicator.hidden = YES;
        
    } else {
        self.numIndicator.hidden = NO;
        [self.placeholderLabel removeFromSuperview];
    }

    self.numIndicator.text = [NSString stringWithFormat:@"%d", 140 - /*nonSpaceTextLength*/[self.helpTextView.text length]];
    
    [self turnOnSendEnabled];

}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![theTextView hasText]) {
        [theTextView addSubview:self.placeholderLabel];
        self.numIndicator.hidden = YES;
    } else {
        [self.placeholderLabel removeFromSuperview];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    
    if (textView.text.length + [text length] > 140){
        
        return NO;
    } 
    
    return YES;
}


# pragma mark - keyboard show event for resize the UI
- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    NSValue *endingFrame = [[notif userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame;
    [endingFrame getValue:&frame];
    
    CGRect uvFrame = self.uv.frame;
    CGRect contentFrame = self.helpTextView.frame;
    
    uvFrame.origin.y = 411.0f - (frame.size.height + 32.0f);
    contentFrame.size.height = 411.0f - (frame.size.height + 32.0f);
    
    self.uv.frame = uvFrame;
    self.helpTextView.frame = contentFrame;
    
}

#pragma mark - actions
-(IBAction)poiFindAction:(id)sender
{
    POIViewController *poivc = [[POIViewController alloc] initWithNibName:@"POIViewController" bundle:nil];
    poivc.helpVc = self;
    [self presentModalViewController:poivc animated:YES];
    [poivc release];
}

-(IBAction)topicAction:(id)sender
{
    self.helpTextView.text = [NSString stringWithFormat:@"%@##", self.helpTextView.text];
    self.helpTextView.selectedRange = NSMakeRange(self.helpTextView.text.length - 1, 0);
}

@end
