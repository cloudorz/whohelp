//
//  MyProfileViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "Utils.h"
#import "CustomItems.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileManager.h"

@implementation MyProfileViewController

@synthesize image=image_;
@synthesize  appView, contentView, descContentView, mainView, nameField, phoneField;
@synthesize  avatarImage, doubanImage, renrenImage, weiboImage;

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
    // TODO
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    NSLog(@"save it now");
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

-(IBAction)doubanAction:(id)sender
{
    NSLog(@"I'm douban");
}

-(IBAction)renrenAction:(id)sender
{
    NSLog(@"I'm renren");
}

-(IBAction)weiboAction:(id)sender
{
    NSLog(@"I'm weibo");
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

#pragma mark - Text field delegate
#pragma mark - dimiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"done the editing change");
//    if(![textView hasText]) {
//        
//        [textView addSubview:self.placeholderLabel];
//        self.numIndicator.hidden = YES;
//        
//    } else if ([[textView subviews] containsObject:self.placeholderLabel]) {
//        
//        [self.placeholderLabel removeFromSuperview];
//        self.numIndicator.hidden = NO;
//        
//    }
//    
//    //NSInteger nonSpaceTextLength = [[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
//    self.numIndicator.text = [NSString stringWithFormat:@"%d", 70 - /*nonSpaceTextLength*/[self.helpTextView.text length]];
//    
//    [self turnOnSendEnabled];
    
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
//    if (![theTextView hasText]) {
//        [theTextView addSubview:self.placeholderLabel];
//        self.numIndicator.hidden = YES;
//    }
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
    if ([text isEqualToString:@"\n"] || textView.text.length + [text length] > 70){
        return NO;
    } 
    
    return YES;
}

#pragma mark - dimiss the keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    [self.descContentView resignFirstResponder];
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
    

    [Utils uploadImageFromData:self.image];
    
    // first save to profile
    [ProfileManager sharedInstance].profile.avatar = self.image;
    
    // change current avatar
    self.avatarImage.image = [UIImage imageWithData:self.image];
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    
}

@end
