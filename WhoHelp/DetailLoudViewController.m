//
//  DetailLoudViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailLoudViewController.h"
#import "Config.h"
#import "ProfileManager.h"
#import "UserManager.h"
//#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "LocationController.h"

@implementation DetailLoudViewController

@synthesize loud=loud_;
@synthesize tableview=tableview_;

- (void)dealloc
{
    [loud_ release];
    [tableview_ release];
    [loudCates_ release];
    [payCates_ release];
    [super dealloc];
}

- (NSDictionary *)loudCates
{
    if (nil == loudCates_){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"LoudCate" ofType:@"plist"];
        loudCates_ = [[NSDictionary alloc] initWithContentsOfFile:myFile];
    }
    
    return loudCates_;
}

- (NSDictionary *)payCates
{
    if (nil == payCates_){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"payCate" ofType:@"plist"];
        payCates_ = [[NSDictionary alloc] initWithContentsOfFile:myFile];
        
    }
    
    return payCates_;
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
    
    // common variables
    UIColor *bgColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
    UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
    
    // common variables - current user
    NSDictionary *userLink = [self.loud objectForKey:@"user"];
    __block NSDictionary *user = nil;
    [[UserManager sharedInstance] fetchUserRequestWithLink:userLink forBlock:^(NSDictionary *data){
        user = data;
    }];
    
    // common variables - check is owner
    isOwner = [[ProfileManager sharedInstance].profile.urn isEqual:[user objectForKey:@"id"]];
    
    // navigation bar title
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 5, 220, 30)] autorelease];
    label.text =[NSString stringWithFormat:@"%@的求助", 
                 isOwner ? @"我" :[user objectForKey:@"name"]];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = label;
    
    // root view
    self.view.backgroundColor = [UIColor whiteColor];
    
    // top line 
    UIImageView *topLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableheader.png"]] autorelease];
    topLine.frame = CGRectMake(0, 0, 320, 5);
    topLine.opaque = YES;
    
    [self.view addSubview:topLine];
    
    
    // user header
    UIView *userHeader = [[[UIView alloc] initWithFrame:CGRectMake(0, 5, 320, 61)] autorelease];
    userHeader.backgroundColor = bgColor;
    
    // user header - avatar
    UIImageView *userAvatar = [[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 35, 35)] autorelease];
    userAvatar.opaque = YES;
    userAvatar.backgroundColor = [UIColor clearColor];
    //userAvatar.layer.cornerRadius = .0;
    [userAvatar retain];
    [[UserManager sharedInstance] fetchPhotoRequestWithLink:user forBlock:^(NSData *data){
        userAvatar.image = [UIImage imageWithData:data];
        [userAvatar release];
    }];
    [userHeader addSubview:userAvatar];
    
    UIImageView *avatarFrame = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatarFrameGray.png"]] autorelease];
    avatarFrame.frame = CGRectMake(12, 13, 35, 36);
    avatarFrame.backgroundColor = [UIColor clearColor];
    [userHeader addSubview:avatarFrame];
    
    // user header - name
    UILabel *userName = [[[UILabel alloc] initWithFrame:CGRectMake(58, 14, 100, 14)] autorelease];
    userName.opaque = YES;
    userName.textColor = [UIColor blackColor];
    userName.backgroundColor = [UIColor clearColor];
    userName.font = [UIFont boldSystemFontOfSize: NAMEFONTSIZE];
    userName.text = [user objectForKey:@"name"];
    [userHeader addSubview:userName];
    
    // user header - meta infomation
    UILabel *userMeta = [[[UILabel alloc] initWithFrame:CGRectMake(58, 24+NAMEFONTSIZE, 100, 12)] autorelease];
    userMeta.opaque = YES;
    
    userMeta.textColor = [UIColor colorWithRed:166/255.0 green:157/255.0 blue:152/255.0 alpha:1.0];
    userMeta.backgroundColor = [UIColor clearColor];
    userMeta.font = [UIFont systemFontOfSize: 10.0f];
    userMeta.text = [NSString stringWithFormat:@"帮助 %@  好评 %@", [user objectForKey:@"to_help_num"], [user objectForKey:@"star_num"]];
    [userHeader addSubview:userMeta];
    
    if (isOwner){
        int justlook_num = [[self.loud objectForKey:@"reply_num"] intValue] - [[self.loud objectForKey:@"help_num"] intValue];
        
        // offer help number
        UIImageView *offerHelpImage = [[[UIImageView alloc] initWithFrame:CGRectMake(204, 13, 28, 36)] autorelease];
        offerHelpImage.opaque = YES;
        offerHelpImage.backgroundColor = [UIColor clearColor];
        offerHelpImage.image = [UIImage imageNamed:@"offerhelpnum.png"];
        
        UILabel *offerHelpLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 24, 10)];
        offerHelpLabel.textAlignment = UITextAlignmentCenter;
        offerHelpLabel.font = [UIFont boldSystemFontOfSize: SMALLFONTSIZE];
        offerHelpLabel.textColor = [UIColor whiteColor];
        offerHelpLabel.lineBreakMode = UILineBreakModeTailTruncation;
        offerHelpLabel.numberOfLines = 1;
        offerHelpLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        offerHelpLabel.backgroundColor = [UIColor clearColor];
        offerHelpLabel.text = [NSString stringWithFormat:@"%@", [self.loud objectForKey:@"help_num"]];
        
        [offerHelpImage addSubview:offerHelpLabel];
        [userHeader addSubview:offerHelpImage];
        
        // just look for fun number
        UIImageView *justLookImage = [[[UIImageView alloc] initWithFrame:CGRectMake(242, 13, 28, 36)] autorelease];
        justLookImage.opaque = YES;
        justLookImage.backgroundColor = [UIColor clearColor];
        justLookImage.image = [UIImage imageNamed:@"justlooknum.png"];
       
        UILabel *justLookLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 24, 10)];
        justLookLabel.textAlignment = UITextAlignmentCenter;
        justLookLabel.font = [UIFont boldSystemFontOfSize: SMALLFONTSIZE];
        justLookLabel.textColor = [UIColor whiteColor];
        justLookLabel.lineBreakMode = UILineBreakModeTailTruncation;
        justLookLabel.numberOfLines = 1;
        justLookLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        justLookLabel.backgroundColor = [UIColor clearColor];
        justLookLabel.text = [NSString stringWithFormat:@"%d", justlook_num];
        
        [justLookImage addSubview:justLookLabel];
        [userHeader addSubview:justLookImage];
        
        // help done
        UIImageView *helpDoneImage = [[[UIImageView alloc] initWithFrame:CGRectMake(280, 13, 28, 36)] autorelease]; // FIXME a button ?
        helpDoneImage.opaque = YES;
        helpDoneImage.backgroundColor = [UIColor clearColor];
        helpDoneImage.image = [UIImage imageNamed:@"helpdone.png"];
        
        UILabel *helpDoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 24, 10)];
        helpDoneLabel.textAlignment = UITextAlignmentCenter;
        helpDoneLabel.font = [UIFont boldSystemFontOfSize: SMALLFONTSIZE];
        helpDoneLabel.textColor = [UIColor whiteColor];
        helpDoneLabel.lineBreakMode = UILineBreakModeTailTruncation;
        helpDoneLabel.numberOfLines = 1;
        helpDoneLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        helpDoneLabel.backgroundColor = [UIColor clearColor];
        helpDoneLabel.text = @"完成";
        
        [helpDoneImage addSubview:helpDoneLabel];
        [userHeader addSubview:helpDoneImage];
    } else{
        UIImageView *offerHelpImage = [[[UIImageView alloc] initWithFrame:CGRectMake(242, 13, 28, 36)] autorelease];
        offerHelpImage.opaque = YES;
        offerHelpImage.backgroundColor = [UIColor clearColor];
        offerHelpImage.image = [UIImage imageNamed:@"offerhelp.png"];
        
        UILabel *offerHelpLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 24, 10)];
        offerHelpLabel.textAlignment = UITextAlignmentCenter;
        offerHelpLabel.font = [UIFont boldSystemFontOfSize: SMALLFONTSIZE];
        offerHelpLabel.textColor = [UIColor whiteColor];
        offerHelpLabel.lineBreakMode = UILineBreakModeTailTruncation;
        offerHelpLabel.numberOfLines = 1;
        offerHelpLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        offerHelpLabel.backgroundColor = [UIColor clearColor];
        offerHelpLabel.text = @"帮助";
        
        [offerHelpImage addSubview:offerHelpLabel];
        [userHeader addSubview:offerHelpImage];
        
        UIImageView *justLookImage = [[[UIImageView alloc] initWithFrame:CGRectMake(280, 13, 28, 36)] autorelease];
        justLookImage.opaque = YES;
        justLookImage.backgroundColor = [UIColor clearColor];
        justLookImage.image = [UIImage imageNamed:@"justlook.png"];
        
        UILabel *justLookLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 24, 10)];
        justLookLabel.textAlignment = UITextAlignmentCenter;
        justLookLabel.font = [UIFont boldSystemFontOfSize: SMALLFONTSIZE];
        justLookLabel.textColor = [UIColor whiteColor];
        justLookLabel.lineBreakMode = UILineBreakModeTailTruncation;
        justLookLabel.numberOfLines = 1;
        justLookLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
        justLookLabel.backgroundColor = [UIColor clearColor];
        justLookLabel.text = @"围观";
        
        [justLookImage addSubview:justLookLabel];
        [userHeader addSubview:justLookImage];
    }
    
    // user header bottome line
    UILabel *bottomLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 1)] autorelease];
    bottomLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:229/255.0 blue:226/255.0 alpha:1.0];
    bottomLine.opaque = YES;
    
    [userHeader addSubview:bottomLine];
    
    [self.view addSubview:userHeader];
    
    
    // conetent  put below in table header view
    
    CGSize theSize= [[self.loud objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                               constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                   lineBreakMode:UILineBreakModeWordWrap];
    CGFloat contentHeight = theSize.height;
    CGFloat heightForAll = 67 + contentHeight + SMALLFONTSIZE;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, 320, heightForAll)];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *contentText = [[[UILabel alloc] initWithFrame:CGRectMake(58,  10, TEXTWIDTH, contentHeight)] autorelease];
    contentText.textAlignment = UITextAlignmentLeft;
    contentText.lineBreakMode = UILineBreakModeWordWrap;
    contentText.numberOfLines = 0;
    contentText.font = [UIFont systemFontOfSize:TEXTFONTSIZE];
    contentText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    contentText.opaque = YES;
    contentText.backgroundColor = [UIColor clearColor];
    contentText.text = [self.loud objectForKey:@"content"];
    
    [tableHeaderView addSubview:contentText];
    
    // loud category color show
    UILabel *loudCateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 20+contentHeight, 320, 24)] autorelease];
    loudCateLabel.backgroundColor = [UIColor orangeColor]; 
    loudCateLabel.opaque = YES;
    
    UILabel *payCateDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 0, TEXTWIDTH, 24)] autorelease];
    payCateDescLabel.textAlignment = UITextAlignmentLeft;
    payCateDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    payCateDescLabel.font = [UIFont boldSystemFontOfSize:NAMEFONTSIZE];
    payCateDescLabel.textColor = [UIColor whiteColor];
    payCateDescLabel.numberOfLines = 1;
    payCateDescLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingNone;
    payCateDescLabel.backgroundColor = [UIColor clearColor];
    [loudCateLabel addSubview:payCateDescLabel];
    
    // loud category and pay category image show
    UIImageView *loudCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(13, 16+contentHeight, 32, 32)] autorelease];
    loudCateImage.opaque = YES;
    loudCateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
    UIImageView *payCateImage = [[[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 24, 24)] autorelease];
    payCateImage.backgroundColor = [UIColor clearColor];
    
    [loudCateImage addSubview:payCateImage];
    
    // loud categories and pay categories
    NSDictionary *loudcate = [self.loudCates objectForKey:[self.loud objectForKey:@"loudcate"]];
    NSDictionary *paycate = [self.payCates objectForKey:[self.loud objectForKey:@"paycate"]];
    
    if (nil != loudcate){
        NSArray *loudColor = [loudcate objectForKey:@"color"];
        //NSLog(@"loudcate %@ color: %@,%@,%@", [loudcate objectForKey:@"label"], [loudColor objectAtIndex:0], [loudColor objectAtIndex:1], [loudColor objectAtIndex:2]);
        loudCateLabel.backgroundColor = [UIColor colorWithRed:[[loudColor objectAtIndex:0] intValue]/255.0 
                                                        green:[[loudColor objectAtIndex:1] intValue]/255.0 
                                                         blue:[[loudColor objectAtIndex:2] intValue]/255.0 
                                                        alpha:1.0];
        loudCateImage.image = [UIImage imageNamed:[loudcate objectForKey:@"colorPic"]];
    }
    
    if (nil != paycate){
        //NSLog(@"paycate %@ %@,%@", [paycate objectForKey:@"label"], [paycate objectForKey:@"logo"], [paycate objectForKey:@"showPic"]);
        payCateImage.image = [UIImage imageNamed:[paycate objectForKey:@"showPic"]];
    }
    
    // pay categories description
    if ([NSNull null] == [self.loud objectForKey:@"paydesc"]){
        payCateDescLabel.text = [paycate objectForKey:@"text"];
    } else{
        payCateDescLabel.text = [NSString stringWithFormat:@"%@, %@",
                                 [paycate objectForKey:@"text"],
                                 [self.loud objectForKey:@"paydesc"]];
    }
    
    [tableHeaderView addSubview:loudCateLabel];
    [tableHeaderView addSubview:loudCateImage];
    
    // location descrtion
    UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 55+contentHeight, 180, SMALLFONTSIZE+2)] autorelease];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
    locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE, SMALLFONTSIZE);
    locationImage.backgroundColor = [UIColor clearColor];
    [locationLabel addSubview:locationImage];
    
    UILabel *locationDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 150, SMALLFONTSIZE+2)] autorelease];
    locationDescLabel.textAlignment = UITextAlignmentLeft;
    locationDescLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    locationDescLabel.textColor = smallFontColor;
    locationDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    locationDescLabel.numberOfLines = 1;
    locationDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    locationDescLabel.backgroundColor = [UIColor clearColor];
    
    locationDescLabel.text =[Utils postionInfoFrom:[LocationController sharedInstance].location toLoud:self.loud];
    
    [locationLabel addSubview:locationDescLabel];
    
    [tableHeaderView addSubview:locationLabel];
    
    // comment infomation
    UILabel *commentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(258, 55+contentHeight, 50, SMALLFONTSIZE+2)] autorelease]; // show
    commentLabel.opaque = YES;
    commentLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    commentLabel.textAlignment = UITextAlignmentRight;
    commentLabel.textColor = smallFontColor;
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    
    //timeLabel.backgroundColor = bgGray;
    UIImageView *commentImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment.png"]] autorelease];
    commentImage.frame = CGRectMake(0, 1, SMALLFONTSIZE, SMALLFONTSIZE);
    commentImage.backgroundColor = [UIColor clearColor];
    
    // comments 
    if ([[self.loud objectForKey:@"reply_num"] intValue] >= 0){
        commentLabel.hidden = NO;
        commentLabel.text = [NSString stringWithFormat:@"%d条评论", [[self.loud objectForKey:@"reply_num"] intValue]];
        
    } else {
        commentLabel.hidden = YES;
    }
    
    [commentLabel addSubview:commentImage];
    
    [tableHeaderView addSubview:commentLabel];
    
    
    UILabel *cbottomLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, heightForAll-1, 320, 1)] autorelease];
    cbottomLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:229/255.0 blue:226/255.0 alpha:1.0];
    cbottomLine.opaque = YES;
    
    [tableHeaderView addSubview:cbottomLine];
    
    // tableview
    self.tableview.backgroundColor = bgColor;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.tableHeaderView = tableHeaderView;
    CGRect tableFrame = self.tableview.frame;
    tableFrame.size.height -= 66;
    tableFrame.origin.y += 66;
    self.tableview.frame = tableFrame;
    
    // navigation item left
   // self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"backup.png"];
    self.navigationController.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"backup.png"];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
