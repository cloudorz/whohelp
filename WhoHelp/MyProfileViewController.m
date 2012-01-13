//
//  MyProfileViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "ASIFormDataRequest.h"
#import "Utils.h"
#import "Config.h"
#import "CustomItems.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileManager.h"
#import "UserManager.h"
#import "AuthPageViewController.h"

@implementation MyProfileViewController

@synthesize image=image_;
@synthesize appView, contentView, descContentView, mainView, nameField, phoneField;
@synthesize avatarImage, doubanImage, renrenImage, weiboImage;
@synthesize weiboSwitch, doubanSwitch, renrenSwitch;

-(void)dealloc
{
    [image_ release];
    [appView release];
    [contentView release];
    [descContentView release];
    [mainView release];
    [nameField release];
    [phoneField release];
    [avatarImage release];
    [doubanImage release];
    [renrenImage release];
    [weiboImage release];
    [weiboSwitch release];
    [doubanSwitch release];
    [renrenSwitch release];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // navigation item config
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                               initSaveBarButtonItemWithTarget:self 
                                               action:@selector(saveButtonPressed:)] autorelease];
    
    self.navigationItem.titleView = [[[NavTitleLabel alloc] initWithTitle:@"编辑资料"] autorelease];
    
    self.contentView.clipsToBounds = NO;
    [self.contentView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.contentView.layer setShadowRadius:0.7f];
    [self.contentView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.contentView.layer setShadowOpacity:0.25f];
    [self.contentView.layer setCornerRadius:5.0f];
    
    self.appView.clipsToBounds = NO;
    [self.appView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.appView.layer setShadowRadius:0.7f];
    [self.appView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.appView.layer setShadowOpacity:0.25f];
    [self.appView.layer setCornerRadius:5.0f];
    
    // init the data
    self.nameField.text = [ProfileManager sharedInstance].profile.name;
    if ([ProfileManager sharedInstance].profile.phone != nil){
        self.phoneField.text = [ProfileManager sharedInstance].profile.phone;
    }
    self.descContentView.text = [ProfileManager sharedInstance].profile.brief;
    self.avatarImage.image = [UIImage imageWithData:[ProfileManager sharedInstance].profile.avatar];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // init the third party
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:self.nameField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:self.phoneField];
    
    // init the auths
    if ([ProfileManager sharedInstance].profile.weibo != nil) {
        self.weiboImage.image = [UIImage imageNamed:@"weiboo.png"];
        self.weiboSwitch.on = YES;
    } else{
        self.weiboImage.image = [UIImage imageNamed:@"weibox.png"];
        self.weiboSwitch.on = NO;
    }
    
    if ([ProfileManager sharedInstance].profile.douban != nil) {
        self.doubanImage.image = [UIImage imageNamed:@"doubano.png"];
        self.doubanSwitch.on = YES;
    } else{
        self.doubanImage.image = [UIImage imageNamed:@"doubanx.png"];
        self.doubanSwitch.on = NO;
    } 
    
    if ([ProfileManager sharedInstance].profile.renren != nil) {
        self.renrenImage.image = [UIImage imageNamed:@"renreno.png"];
        self.renrenSwitch.on = YES;
    } else{
        self.renrenImage.image = [UIImage imageNamed:@"renrenx.png"];
        self.renrenSwitch.on = NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextFieldTextDidChangeNotification 
                                                  object:self.nameField];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UITextFieldTextDidChangeNotification 
                                                  object:self.phoneField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)testPhoneNumber:(NSString *)num
{
    NSString *decimalRegex = @"^[0-9]{11}$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    return [decimalTest evaluateWithObject:num];
}

-(NSString *)nilToEmptyString:(id)obj
{
    if (obj == nil){
        return @"";
    }
    
    return obj;
}

-(void)turnSaveButtonEnable
{
    BOOL nameStatus = [[self nilToEmptyString:[ProfileManager sharedInstance].profile.name ] isEqual:self.nameField.text];
    BOOL phoneStatus = [[self nilToEmptyString:[ProfileManager sharedInstance].profile.phone ] isEqual:self.phoneField.text];
    BOOL briefStatus = [[self nilToEmptyString:[ProfileManager sharedInstance].profile.brief ] isEqual:self.descContentView.text];
    
    if (!(nameStatus && phoneStatus && briefStatus)) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else{
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - actions
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    if ([[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        [Utils warningNotification:@"昵称不能为空"];
        return;
    }
    
    if (![self.phoneField.text isEqualToString:@""] && ![self testPhoneNumber:self.phoneField.text]) {
        
        [Utils warningNotification:@"填写的手机号无效"];
        return;
    } 
    
    // send it no

    [self updateUserInfo];

}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

-(IBAction)doubanAction:(id)sender
{

    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        
        [self authRequest:@"/douban/auth"];
        
    } else{
        [self delAuthRequest:[ProfileManager sharedInstance].profile.douban block:^(BOOL success){
            if (success) {
                [ProfileManager sharedInstance].profile.douban = nil;
                self.doubanImage.image = [UIImage imageNamed:@"doubanx.png"];
            } else {
                self.doubanSwitch.on = YES;
            }

            
        }];
    }
 
}

-(IBAction)renrenAction:(id)sender
{

    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        
        [self authRequest:@"/renren/auth"];
        
    } else{
        [self delAuthRequest:[ProfileManager sharedInstance].profile.renren block:^(BOOL success){
            if (success) {
                [ProfileManager sharedInstance].profile.renren = nil;
                self.renrenImage.image = [UIImage imageNamed:@"renrenx.png"];
            } else {
                self.renrenSwitch.on = YES;
            }
            
            
        }];
    }
}

-(IBAction)weiboAction:(id)sender
{
    
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        
        [self authRequest:@"/weibo/auth"];
        
    } else{
        [self delAuthRequest:[ProfileManager sharedInstance].profile.weibo block:^(BOOL success){
            if (success) {
                [ProfileManager sharedInstance].profile.weibo = nil;
                self.weiboImage.image = [UIImage imageNamed:@"weibox.png"];
            } else {
                self.weiboSwitch.on = YES;
            }
            
            
        }];
    }
}

-(IBAction)avatarAction:(id)sender
{

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                                delegate:self 
                                                       cancelButtonTitle:@"取消" 
                                                  destructiveButtonTitle:nil 
                                                       otherButtonTitles:@"拍照", @"从相册中选取", nil];
        
        [photoSheet showFromTabBar:self.tabBarController.tabBar];
        [photoSheet release];
        
    } else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            picker.allowsEditing = YES;
            [self presentModalViewController:picker animated:YES];
        }
}


#pragma mark - remote operations

-(void)delAuthRequest:(NSString *)urlString block:(void (^)(BOOL))callback
{
    NSURL *url = [NSURL URLWithString:urlString];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        
        NSInteger code = [request responseStatusCode];
        if (200 == code){
            
            callback(YES);
            
        } else if (412 == code){
            callback(NO);
            [Utils warningNotification:@"至少保留一个授权"];
        } else{
            callback(NO);
            [Utils warningNotification:@"取消授权失败"];
        }
        
    }];
    
    [request setFailedBlock:^{
        
        NSError *error = [request error];
        [Utils warningNotification:[error description]];
        callback(NO);
        NSLog(@"%@", [error description]);
        
    }];
    [request setRequestMethod:@"DELETE"];
    [request signInHeader];
    [request startAsynchronous]; 
}

- (void)authRequest: (NSString *)path
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, path]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestAuthFailed:)];
    [request setDidFinishSelector:@selector(requestAuthFinished:)];
    [request signInHeader]; // must have this
    [request startAsynchronous];
}

- (void)requestAuthFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    AuthPageViewController *webVC = [[AuthPageViewController alloc] initWithNibName:@"AuthPageViewController" bundle:nil];
    
    webVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    webVC.baseURL = request.url;
    webVC.body = responseString;
    [self.navigationController pushViewController:webVC animated:YES];
    
    [webVC release];
    
}

- (void)requestAuthFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    [Utils warningNotification:[error description]];
    NSLog(@"%@", [error description]);
}


- (void)updateUserInfo
{
     self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSDictionary *preInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"name",
                             [self.descContentView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"brief",
                             [self testPhoneNumber:self.phoneField.text] ? self.phoneField.text : nil, @"phone",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[ProfileManager sharedInstance].profile.link];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[preInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"PUT"];
    // sign to header for authorize
    [request signInHeader];
    [request setDelegate:self];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if ([request responseStatusCode] == 200){
        
        // update profile
        [ProfileManager sharedInstance].profile.name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ProfileManager sharedInstance].profile.brief = [self.descContentView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ProfileManager sharedInstance].profile.phone = [self testPhoneNumber:self.phoneField.text] ? self.phoneField.text : nil;
        
        // udpate the user cache ??
       
        
    } else if (400 == [request responseStatusCode]) {
        [Utils warningNotification:@"参数错误"];
    } else{
        [Utils warningNotification:@"非正常返回"];
    }
    
    // send ok cancel

    [self turnSaveButtonEnable];
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self turnSaveButtonEnable];
    [Utils warningNotification:[[request error] localizedDescription]];
    
}

#pragma mark - Text field delegate
#pragma mark - dimiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(UITextField *)textField
{
    [self turnSaveButtonEnable];
}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{

    [self turnSaveButtonEnable];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect viewFrame = self.mainView.frame;
    viewFrame.origin.y = -222.0f;
    self.mainView.frame = viewFrame;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //NSInteger inputedTextLength = [textView.text length];
    if ([text isEqualToString:@"\n"]){
        
        [textView resignFirstResponder];
        
        CGRect viewFrame = self.mainView.frame;
        viewFrame.origin.y = 5.0f;
        self.mainView.frame = viewFrame;
        
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

    [self.descContentView resignFirstResponder];
    // test
    [self.nameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    
    CGRect viewFrame = self.mainView.frame;
    viewFrame.origin.y = 5.0f;
    self.mainView.frame = viewFrame;
}


#pragma mark - actionsheetp delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    // handle photo
    switch (buttonIndex) {
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
                picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            } else {
                picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    [self presentModalViewController:picker animated:YES];
        

    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    self.image = UIImageJPEGRepresentation([Utils thumbnailWithImage:[info objectForKey:UIImagePickerControllerEditedImage] size:CGSizeMake(70.0f, 70.0f)], 0.65f);
    

    [self uploadImageFromData:self.image];
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    
}

#pragma mark - reques upload http
- (void)uploadImageFromData:(NSData *)avatarData
{
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, UPLOADURI]]];
    [request setData:avatarData withFileName:@"avatar.jpg" andContentType:@"image/jpg" forKey:@"photo"];
    [request setRequestMethod:@"POST"]; // set this, otherwise sign dismatch
           
    [request setCompletionBlock:^{
        // Use when fetching text data
        
        NSInteger code = [request responseStatusCode];
        if (200 == code){
            // first save to profile
            [ProfileManager sharedInstance].profile.avatar = self.image;
            
            // change current avatar
            self.avatarImage.image = [UIImage imageWithData:self.image];
            
            // change the photo cache
            NSMutableDictionary *photo = [[UserManager sharedInstance].photoCache objectForKey:[ProfileManager sharedInstance].profile.urn];
            if (photo != nil){
                [photo setObject:self.image forKey:@"avatar"];
            }
            
        } else if (400 == code){
            [Utils warningNotification:@"上传头像失败"];
        } else{
            [Utils warningNotification:@"服务器异常返回"];
        }
        
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Fetch avatar: %@", [error localizedDescription]);
    }];
    
    
    [request signInHeader];
    [request startAsynchronous];

    
}


@end
