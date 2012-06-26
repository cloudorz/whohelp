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
#import "CustomItems.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileManager.h"

@implementation MyProfileViewController

@synthesize image=_image;
@synthesize appView=_appView;
@synthesize contentView=_contentView;
@synthesize descContentView=_descContentView;
@synthesize mainView=_mainView;
@synthesize phoneField=_phoneField;
@synthesize avatarImage=_avatarImage;
@synthesize nameField=_nameField;


-(void)dealloc
{
    [_image release];
    [_appView release];
    [_contentView release];
    [_descContentView release];
    [_mainView release];
    [_nameField release];
    [_phoneField release];
    [_avatarImage release];

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
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
    [self.avatarImage loadImage:[ProfileManager sharedInstance].profile.avatar_link];
    
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
    NSString *decimalRegex = @"^([0-9]{11})|(([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1})|([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1}))$";
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
        [self fadeOutMsgWithText:@"昵称不能为空" rect:CGRectMake(0, 0, 80, 66)];
        return;
    }
    
    if (![self.phoneField.text isEqualToString:@""] && ![self testPhoneNumber:self.phoneField.text]) {
        
        [self fadeOutMsgWithText:@"无效号码" rect:CGRectMake(0, 0, 80, 66)];
        return;
    } 
    
    // send it no

    [self updateUserInfo];

}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
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


//- (void)authRequest: (NSString *)path
//{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST, path]];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request setDelegate:self];
//    [request setDidFailSelector:@selector(requestAuthFailed:)];
//    [request setDidFinishSelector:@selector(requestAuthFinished:)];
//    [request signInHeader]; // must have this
//    [request startAsynchronous];
//}

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
       [self fadeInMsgWithText:@"保存成功" rect:CGRectMake(0, 0, 60, 66)];
        
    } else{

        [self fadeOutMsgWithText:@"保存失败" rect:CGRectMake(0, 0, 60, 66)];
    }
    
    // send ok cancel

    [self turnSaveButtonEnable];
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self turnSaveButtonEnable];
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
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
    viewFrame.origin.y = -60.0f;
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
            
            // change current avatar
            self.avatarImage.image = [UIImage imageWithData:self.image];
            
            
            [self fadeInMsgWithText:@"上传头像成功" rect:CGRectMake(0, 0, 80, 66)];
            
        } else{

            [self fadeOutMsgWithText:@"上传头像失败" rect:CGRectMake(0, 0, 80, 66)];
        }
        
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Fetch avatar: %@", [error localizedDescription]);
        [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    }];
    
    
    [request signInHeader];
    [request startAsynchronous];

    
}


@end
