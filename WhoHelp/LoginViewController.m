//
//  LoginViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "WhoHelpAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Config.h"
#import "Profile.h"
#import "ResetPasswordViewController.h"
#import "SignupViewController.h"

@implementation LoginViewController

@synthesize loadingIndicator=loadingIndicator_;
@synthesize phone=phone_;
@synthesize pass=pass_;

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
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
//    [tap release];
    // Do any additional setup after loading the view from its nib.
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.loadingIndicator stopAnimating];
}

#pragma mark - action login forgot password
- (IBAction)loginButtonPressed:(id)sender
{
    [sender setEnabled: NO];
    
    NSString *inputPhone = self.phone.text;
    NSString *inputPass = self.pass.text;
    NSString *decimalRegex = @"^[0-9]{11}$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    
    if ([inputPass length] >0 && [decimalTest evaluateWithObject:inputPhone]){
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setObject:inputPhone forKey:@"phone"];
        [data setObject:inputPass forKey:@"password"];
        
        [self postUserInfo:data];
        [data release];
    }else{
        [self warningNotification:@"手机号(11位数字)与密码不能为空"];
    }

    [sender setEnabled: YES];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender
{
    ResetPasswordViewController *resetPVC = [[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
    [self presentModalViewController:resetPVC animated:YES];
    [resetPVC release];
}

- (IBAction)signupButtonPressed:(id)sender
{

    SignupViewController *signupVC = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    [self presentModalViewController:signupVC animated:YES];
    [signupVC release];
    
}

-(void)dismissKeyboard {
    [self.phone resignFirstResponder];
    [self.pass resignFirstResponder];
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
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

#pragma mark - get the images
- (void)postUserInfo: (NSMutableDictionary *)userInfo
{
    [self.loadingIndicator startAnimating];
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:userInfo];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?ak=%@", AUTHURI, APPKEY]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
                
            [self saveUserInfo:result];
            [self dismissModalViewControllerAnimated:YES];
            
        } else if (406 == [request responseStatusCode]) {
            [self warningNotification:@"登录失败请输入正确的手机号和密码"];
        } else if (400 == [request responseStatusCode]) {
            [self warningNotification:@"参数不正确"];
        }else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
    [self.loadingIndicator stopAnimating];
}

- (void)saveUserInfo:(NSMutableDictionary *) data
{
   
    Profile *profile = (Profile *)[self getProfileByPhone:[data objectForKey:@"phone"]];
    
    if (profile == nil){
        profile =  (Profile *)[NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    profile.name = [data objectForKey:@"name"];
    profile.phone = [data objectForKey:@"phone"];
    profile.token = [data objectForKey:@"token"];
    profile.updated = [dateFormatter dateFromString:[data objectForKey:@"updated"]];
    profile.isLogin = [NSNumber numberWithBool:TRUE];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Handle the error. 
        [self warningNotification:@"数据存储失败."];
        NSLog(@"save data error: %@, %@", error, [error userInfo]);
    }
    
    [dateFormatter release];
}

#pragma mark - database operation
- (NSManagedObject *)getProfileByPhone:(NSNumber *)phone
{
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"phone == %@", phone]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            
            NSManagedObject *res = [mutableFetchResults objectAtIndex:0];
            [mutableFetchResults release];
            return res;
        }
        
    } else {
        // Handle the error FIXME
        NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
    }
    
    [mutableFetchResults release];
    return nil;
    
}

#pragma mark - dealloc
- (void)dealloc
{
    //[managedObjectContext_ release];
    [phone_ release];
    [pass_ release];
    [loadingIndicator_ release];
    [super dealloc];
}

@end
