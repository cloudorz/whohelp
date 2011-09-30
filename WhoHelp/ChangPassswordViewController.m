//
//  ChangPassswordViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ChangPassswordViewController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "Utils.h"
#import "LoginViewController.h"
#import "WhoHelpAppDelegate.h"

@implementation ChangPassswordViewController

@synthesize oldPassword=oldPassword_;
@synthesize newPassword=newPassword_;
@synthesize repeatPassword=repeatPassword_;
@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize profile=profile_;

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
    
    return managedObjectContext_;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.profile.isLogin == NO){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        LoginViewController *helpLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [appDelegate.tabBarController presentModalViewController:helpLoginVC animated:YES];
        [helpLoginVC release];
    }
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

#pragma mark - actions on view
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender
{
    
    NSMutableAttributedString *attributedString;
    if ([self.oldPassword.text isEqual:@""] || 
        [self.newPassword.text isEqual:@""] || 
        [self.repeatPassword.text isEqual:@""]
        ){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"下面三项必须填写"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
        
        return;
    }
    
    if (![self.newPassword.text isEqual:self.repeatPassword.text]){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"新密码输入不一致"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
        
        return;
    }
    
    self.errorLabel.attributedText = nil;
    
    NSMutableDictionary *passwords = [[NSMutableDictionary alloc] init];
    [passwords setObject:self.oldPassword.text forKey:@"old_password"];
    [passwords setObject:self.newPassword.text forKey:@"password"];
    
    [self.loadingIndicator startAnimating];
    [self postPasswordInfo:passwords];
    [self.loadingIndicator stopAnimating];
    [passwords release];
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    NSLog(@"%d", textField.tag);
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSLog(@"FUCK FUCK");
//    return YES;
//}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images
- (void)postPasswordInfo: (NSMutableDictionary *)passwordInfo
{
    [self.loadingIndicator startAnimating];
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:passwordInfo];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@?ak=%@&tk=%@", USERURI, self.profile.phone, APPKEY, self.profile.token]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"PUT"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
       
            self.profile.isLogin = NO;
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) { 
                [Utils warningNotification:@"数据存储失败."];
            }else{
                [self.navigationController popViewControllerAnimated:NO];
            }  
            
        } else if (412 == [request responseStatusCode]){
            
            NSMutableAttributedString *attributedString;
            attributedString = [NSMutableAttributedString attributedStringWithString:@"密码不正确"];
            [attributedString setFont:[UIFont systemFontOfSize:14.0]];
            [attributedString setTextColor:[UIColor redColor]];
            self.errorLabel.attributedText = attributedString;

        } else if (403 == [request responseStatusCode]) {
            [Utils warningNotification:@"手机号禁止修改"];
        } else{
            [Utils warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [Utils warningNotification:@"请求服务错误"];
    }
}


#pragma mark - dealloc
- (void)dealloc
{
    [oldPassword_ release];
    [newPassword_ release];
    [repeatPassword_ release];
    [errorLabel_ release];
    [loadingIndicator_ release];
    [super dealloc];
}

@end
