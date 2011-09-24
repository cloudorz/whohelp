//
//  LoudManageViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoudManageViewController.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation LoudManageViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize profile=profile_;
@synthesize louds=louds_;
@synthesize buttons=buttons_;


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

- (void)remove3Buttons
{
    if (nil != self.buttons){
        for (UIButton *b in self.buttons) {
            [b removeFromSuperview];
            NSLog(@"fickk kkfdkafda");
        }
        self.buttons = nil;
    }
}

- (void)show3Louds
{
    [self.loadingIndicator startAnimating];
    [self fetch3Louds];
    
    [self remove3Buttons];
    self.buttons = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<3; i++) {
        NSDictionary *loud = [self.louds objectAtIndex:i];
        
        UIButton *entryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        entryButton.frame = CGRectMake(10, 90+47*i, 300, 37);
        entryButton.tag = [[loud objectForKey:@"pk"] integerValue];
        
        entryButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        entryButton.titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        
        [entryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [entryButton setTitle:[loud objectForKey:@"content"] forState:UIControlStateNormal];
        [entryButton setTitleColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] forState:UIControlStateNormal];
        [entryButton addTarget:self action:@selector(entryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:entryButton];
        [self.view addSubview:entryButton];
    }
    [self.loadingIndicator stopAnimating];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loadingIndicator stopAnimating];
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

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self show3Louds];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

#pragma mark - get the three 
- (void)fetch3Louds
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?ak=%@&tk=%@", LOUD3URI, APPKEY, self.profile.token]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
            self.louds = result;
        } else {
            [self warningNotification:@"非常规返回"];
        }

    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

- (IBAction)entryButtonPressed:(id)sender
{
    UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    delSheet.tag = ((UIButton *)sender).tag;
    [delSheet showInView:self.view];
    [delSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%d?ak=%@&tk=%@", SENDURI, actionSheet.tag, APPKEY, self.profile.token]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setRequestMethod:@"DELETE"];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error) {
            if ([request responseStatusCode] == 200){
                SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                id data = [request responseData];
                id result = [jsonParser objectWithData:data];
                [jsonParser release];
                self.louds = result;
                
                if ([[result objectForKey:@"status"] isEqualToString:@"Fail"]){
                    [self warningNotification:@"错误操作"];
                } else{
                    [self show3Louds];
                }
                
            } else {
                [self warningNotification:@"非常规返回"];
            }
            
        }else{
            [self warningNotification:@"请求服务错误"];
        }
    }
}

#pragma mark - actions on view
    
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - handling errors
- (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message
{
    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [Notpermitted show];
    [Notpermitted release];
}

- (void)warningNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"警告" forMessage:message];
}

- (void)errorNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"错误" forMessage:message];  
}

    
- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [louds_ release];
    [buttons_ release];
    [super dealloc];
}

@end
