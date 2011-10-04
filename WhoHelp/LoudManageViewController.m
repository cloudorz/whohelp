//
//  LoudManageViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoudManageViewController.h"
#import "Config.h"
#import "Utils.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "ProfileManager.h"

@implementation LoudManageViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
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
        }
        self.buttons = nil;
    }
}

- (void)show3Louds
{
    [self.loadingIndicator startAnimating];
    [self fetch3Louds];
    
    [self remove3Buttons];
    self.buttons = [[[NSMutableArray alloc] init] autorelease];
    for (NSInteger i=0; i<[self.louds count]; i++) {
        NSDictionary *loud = [self.louds objectAtIndex:i];
        
        UIButton *entryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        entryButton.frame = CGRectMake(10, 90+47*i, 300, 37);
        entryButton.tag = i;
        
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
    // init data from remote server
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
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat: @"%@?ak=%@&tk=%@&q=author:%@&qs=created desc&st=0&qn=3", SURI, APPKEY, [ProfileManager sharedInstance].profile.token, [ProfileManager sharedInstance].profile.phone] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
            self.louds = [result objectForKey:@"louds"];
        } else if (400 == [request responseStatusCode]) {
            [Utils warningNotification:@"参数错误"];
        }else {
            [Utils warningNotification:@"非常规返回"];
        }

    }else{
        [Utils warningNotification:@"请求服务错误"];
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

        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[Utils partURI:[[self.louds objectAtIndex:actionSheet.tag] objectForKey:@"link"] queryString:[NSString stringWithFormat: @"ak=%@&tk=%@", APPKEY, [ProfileManager sharedInstance].profile.token]]];
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
                    [Utils warningNotification:@"错误操作"];
                } else{
                    [self show3Louds];
                }
                
            } else {
                [Utils warningNotification:@"非常规返回"];
            }
            
        }else{
            [Utils warningNotification:@"请求服务错误"];
        }
    }
}

#pragma mark - actions on view
    
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
