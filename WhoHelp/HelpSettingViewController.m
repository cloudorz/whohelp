//
//  HelpSettingViewController.m
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HelpSettingViewController.h"
#import "ChangPassswordViewController.h"
#import "ChangNameViewController.h"
#import "LoudManageViewController.h"
#import "DeleteAccountViewController.h"
#import "LoginViewController.h"
#import "LawViewController.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "Utils.h"
#import "SBJson.h"
#import "ProfileManager.h"

@implementation HelpSettingViewController
@synthesize image=image_;

- (NSMutableArray *)menu
{
    if (nil == menu_){
        menu_ = [[NSMutableArray alloc] init];
        
        NSMutableArray *tmp;
        
        tmp = [[[NSMutableArray alloc] init] autorelease];
        [tmp addObject:@"我的求助"];
        [menu_ addObject:tmp];
        
        tmp = [[[NSMutableArray alloc] init] autorelease];
        [tmp addObject:@"修改昵称"];
        [tmp addObject:@"修改头像"];
        [tmp addObject:@"修改密码"];
        [menu_ addObject:tmp];
        
        tmp = [[[NSMutableArray alloc] init] autorelease];
        [tmp addObject:@"退出登录"];
        [tmp addObject:@"注销帐号"];
        [menu_ addObject:tmp];
        
        tmp = [[[NSMutableArray alloc] init] autorelease];
        [tmp addObject:@"免责声明"];
        [menu_ addObject:tmp];

    }
    
    return menu_;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (0 == section){
        return 1;
    } else if (1 == section){
        return 3;
    } else if (2 == section){
        return 2;
    } else if (3 == section){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    // Configure the cell...
    NSString *menuString = [[self.menu objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]; 
    cell.textLabel.text = menuString;
    if (![menuString isEqualToString:@"退出登录"] && 
        ![menuString isEqualToString:@"修改头像"]){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (0 == indexPath.section && 0 == indexPath.row){
        LoudManageViewController *loudVC = [[LoudManageViewController alloc] initWithNibName:@"LoudManageViewController" bundle:nil];
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:loudVC animated:YES];
        [loudVC release];

    } else if(1 == indexPath.section && 0 == indexPath.row){
        ChangNameViewController *changNameVC = [[ChangNameViewController alloc] initWithNibName:@"ChangNameViewController" bundle:nil];
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changNameVC animated:YES];
        [changNameVC release];
    } else if(1 == indexPath.section && 1 == indexPath.row){
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
    } else if (1 == indexPath.section && 2 == indexPath.row){
        ChangPassswordViewController *changPassVC = [[ChangPassswordViewController alloc] initWithNibName:@"ChangPassswordViewController" bundle:nil];
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changPassVC animated:YES];
        [changPassVC release];

    } else if(2 == indexPath.section && 1 == indexPath.row){
        DeleteAccountViewController *deleteAccountVC = [[DeleteAccountViewController alloc] initWithNibName:@"DeleteAccountViewController" bundle:nil];
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:deleteAccountVC animated:YES];
        [deleteAccountVC release];
    } else if(2 == indexPath.section && 0 == indexPath.row){
        UIActionSheet *logoutSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出登录", nil];
        logoutSheet.tag = 2;
        [logoutSheet showFromTabBar:self.tabBarController.tabBar];
        [logoutSheet release];
    } else if (3 == indexPath.section && 0 == indexPath.row){
        LawViewController *lawVC = [[LawViewController alloc] initWithNibName:@"LawViewController" bundle:nil];
        [self.navigationController pushViewController:lawVC animated:YES];
        [lawVC release];
    }
     
}

#pragma mark - actionsheetp delegate
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"click the button on action sheet");
//}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    
    if (1 == actionSheet.tag) {
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
        
    } else if (2 == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                [[ProfileManager sharedInstance] logout];
                if ([ProfileManager sharedInstance].profile.isLogin == NO){
                    LoginViewController *helpLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    [self.tabBarController presentModalViewController:helpLoginVC animated:YES];
                    [helpLoginVC release];
                }
                break;
                
        }

    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    self.image = UIImageJPEGRepresentation([Utils thumbnailWithImage:[info objectForKey:UIImagePickerControllerEditedImage] size:CGSizeMake(70.0f, 70.0f)], 0.65f);

    [Utils uploadImageFromData:self.image phone:[[ProfileManager sharedInstance].profile.phone stringValue]];
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    
}


- (void)dealloc
{
    [menu_ release];
    [image_ release];
    [super dealloc];
}

@end
