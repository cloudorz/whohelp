//
//  Signup2ViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Signup2ViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Config.h"

@implementation Signup2ViewController

@synthesize errorLabel=errorLabel_;
@synthesize loadingIndicator=loadingIndicator_;
@synthesize phone=phone_;
@synthesize name=name_;
@synthesize password=password_;
@synthesize avatar=avatar_;
@synthesize avatarData=avatarData_;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions on view
- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneButtonPressed:(id)sender
{
    
    [self.loadingIndicator startAnimating];
    [sender setEnabled:NO];
    
    NSMutableAttributedString *attributedString;
    if ([self.name.text isEqualToString:@""]){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"昵称不能为空"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    } else if ([self.password.text isEqualToString:@""]) {
        attributedString = [NSMutableAttributedString attributedStringWithString:@"请设置密码"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    } else if (nil == self.avatarData){
        attributedString = [NSMutableAttributedString attributedStringWithString:@"请设置头像"];
        [attributedString setFont:[UIFont systemFontOfSize:14.0]];
        [attributedString setTextColor:[UIColor redColor]];
        self.errorLabel.attributedText = attributedString;
    }else{
        [self postUserInfo];
    }
    
    [self.loadingIndicator stopAnimating];
    [sender setEnabled:YES];
    
}

- (IBAction)doneEditing:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - get the images
- (void)postUserInfo
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSNumberFormatter *fn = [[NSNumberFormatter alloc] init];
    [fn setNumberStyle:NSNumberFormatterNoStyle];
    [userInfo setObject:[fn numberFromString:self.phone] forKey:@"phone"];
    [userInfo setObject:self.name.text forKey:@"name"];
    [userInfo setObject:self.password.text forKey:@"password"];
    
    SBJsonWriter *preJson = [[SBJsonWriter alloc] init];
    NSString *dataString = [preJson stringWithObject:userInfo];
    [userInfo release];
    [preJson release];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@?ak=%@", USERURI, APPKEY]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=utf-8"];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 201){

            [self dismissModalViewControllerAnimated:YES];
            
        } else if (400 == [request responseStatusCode]) {
            [self warningNotification:@"参数错误"];
        }else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

- (IBAction)takePhoto:(id)sender
{

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选取", nil];
        photoSheet.tag = 1;
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

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
{
    
    UIImage *newimage;
    
    if (nil == image) {        
        newimage = nil;
    }
    else{
        UIGraphicsBeginImageContext(asize);
        
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return newimage;
    
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
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    [self presentModalViewController:picker animated:YES];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    self.avatarData = UIImageJPEGRepresentation([self thumbnailWithImage:[info objectForKey:UIImagePickerControllerEditedImage] size:CGSizeMake(70.0f, 70.0f)], 0.65f);
    self.avatar.image = [UIImage imageWithData:self.avatarData];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?ak=%@", UPLOADURI, APPKEY]]];
    [request setData:self.avatarData withFileName:[NSString stringWithFormat:@"%@.jpg", self.phone] andContentType:@"image/jpg" forKey:@"photo"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            // Nothing
        } else if (400 == [request responseStatusCode]){
            [self warningNotification:@"上传头像失败"];
        } else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    
}

- (void)dealloc
{
    [loadingIndicator_ release];
    [errorLabel_ release];
    [phone_ release];
    [name_ release];
    [password_ release];
    [avatarData_ release];
    [avatar_ release];
    [super dealloc];
}

@end
