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
#import "WhoHelpAppDelegate.h"
#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "SBJson.h"

@implementation HelpSettingViewController
@synthesize image=image_;

- (NSMutableArray *)menu
{
    if (nil == menu_){
        menu_ = [[NSMutableArray alloc] init];
        
        NSMutableArray *tmp;
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"我的求助"];
        [menu_ addObject:tmp];
        [tmp release];
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"修改昵称"];
        [tmp addObject:@"修改头像"];
        [tmp addObject:@"修改密码"];
        [menu_ addObject:tmp];
        [tmp release];
        
        tmp = [[NSMutableArray alloc] init];
        [tmp addObject:@"退出登录"];
        [tmp addObject:@"注销帐号"];
        [menu_ addObject:tmp];
        [tmp release];
    }
    
    return menu_;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil){
        WhoHelpAppDelegate *appDelegate = (WhoHelpAppDelegate *)[[UIApplication sharedApplication] delegate];
        managedObjectContext_ = appDelegate.managedObjectContext;
    }
    
    return managedObjectContext_;
}

- (Profile *)profile
{
    
    // Create request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // config the request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile"  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"isLogin == YES"]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [request release];
    
    if (error == nil) {
        if ([mutableFetchResults count] > 0) {
            
            NSManagedObject *res = [mutableFetchResults objectAtIndex:0];
            profile_ = (Profile *)res;
        }
        
    } else {
        // Handle the error FIXME
        NSLog(@"Get by profile error: %@, %@", error, [error userInfo]);
    }
    
    [mutableFetchResults release];
    
    return profile_;
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
    return 3;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    if (0 == indexPath.section && 0 == indexPath.row){
        LoudManageViewController *loudVC = [[LoudManageViewController alloc] initWithNibName:@"LoudManageViewController" bundle:nil];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:loudVC animated:YES];
        [loudVC release];

    } else if(1 == indexPath.section && 0 == indexPath.row){
        ChangNameViewController *changNameVC = [[ChangNameViewController alloc] initWithNibName:@"ChangNameViewController" bundle:nil];
        changNameVC.profile = self.profile;
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
        changPassVC.profile = self.profile;
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:changPassVC animated:YES];
        [changPassVC release];

    } else if(2 == indexPath.section && 1 == indexPath.row){
        DeleteAccountViewController *deleteAccountVC = [[DeleteAccountViewController alloc] initWithNibName:@"DeleteAccountViewController" bundle:nil];
        deleteAccountVC.profile = self.profile;
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:deleteAccountVC animated:YES];
        [deleteAccountVC release];
    } else if(2 == indexPath.section && 0 == indexPath.row){
        UIActionSheet *logoutSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出登录", nil];
        logoutSheet.tag = 2;
        [logoutSheet showFromTabBar:self.tabBarController.tabBar];
        [logoutSheet release];
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
                NSLog(@"%@", @"action sheet for take photo");
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                NSLog(@"%@", @"get from libaray");
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
        [self presentModalViewController:picker animated:YES];
        
    } else if (2 == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                self.profile.isLogin = NO;
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    // Handle the error. 
                    [self warningNotification:@"数据存储失败."];
                }else{
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

    self.image = UIImageJPEGRepresentation([self thumbnailWithImage:[info objectForKey:UIImagePickerControllerEditedImage] size:CGSizeMake(70.0f, 70.0f)], 0.65f);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?ak=%@&tk=%@", UPLOADURI, APPKEY, self.profile.token]]];
    [request setData:self.image withFileName:[NSString stringWithFormat:@"%@.jpg", self.profile.phone] andContentType:@"image/jpg" forKey:@"photo"];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id data = [request responseData];
            id result = [jsonParser objectWithData:data];
            [jsonParser release];
            
            if ([[result objectForKey:@"status"] isEqualToString:@"Fail"]){
                [self warningNotification:@"上传头像失败"];
            }
        } else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    
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

- (void)dealloc
{
    [menu_ release];
    [image_ release];
    [super dealloc];
}

@end
