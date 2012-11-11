//
//  DetailLoudViewController.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailLoudViewController.h"
#import "ProfileManager.h"
#import "Utils.h"
#import "CustomItems.h"

// lots
#import "ProfileViewController.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "SBJson.h"
#import "DDAlertPrompt.h"
#import "DoubanAuthViewController.h"
#import "OHAttributedLabel.h"

@interface DetailLoudViewController ()

-(void)loadReplyList;

@end

@implementation DetailLoudViewController

@synthesize loudLink=_loudLink;
@synthesize tableView=_tableView;
@synthesize toHelpNumIndicator=_toHelpNumIndicator;
@synthesize starNumIndicator=_starNumIndicator;
@synthesize otherUserView=_otherUserView;
@synthesize myView=_myView;
@synthesize avatarImage=_avatarImage;
@synthesize name=_name;
@synthesize replies=_replies;
@synthesize curCollection=_curCollection;
@synthesize etag=_etag;
@synthesize moreCell=_moreCell;
@synthesize tapUser=_tapUser;
@synthesize textView=_textView;
@synthesize messageView=_messageView;
@synthesize tmpPhoneNum=_tmpPhoneNum;
@synthesize loudDetail=_loudDetail;
@synthesize atUrns=_atUrns;
@synthesize prizeUids=_prizeUids;
@synthesize justLookButton1, justLookButton2, helpDoneButton, phoneButton, sendButton;
@synthesize placeholderLabel=_placeholderLabel;

- (void)dealloc
{
    [_loudLink release];
    [_tableView release];
    [_toHelpNumIndicator release];
    [_starNumIndicator release];
    [_otherUserView release];
    [_myView release];
    [_avatarImage release];
    [_name release];
    [_etag release];
    [_curCollection release];
    [_replies release];
    [_moreCell release];
    [_messageView release];
    [_textView release];
    [_atUrns release];
    [_prizeUids release];
    [_placeholderLabel release];
    [super dealloc];
}

- (NSDictionary *)loudCates
{
    if (nil == _loudCates){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"LoudCate" ofType:@"plist"];
        _loudCates = [[NSDictionary alloc] initWithContentsOfFile:myFile];
    }
    
    return _loudCates;
}

- (NSDictionary *)statuses
{
    if (nil == _statuses){
        // read the plist loud category configure
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"status" ofType:@"plist"];
        _statuses = [[NSDictionary alloc] initWithContentsOfFile:myFile];
    }
    
    return _statuses;
}

- (NSMutableArray *)atUrns
{
    if (_atUrns == nil) {
        _atUrns = [[NSMutableArray alloc] initWithObjects:[[self.loudDetail objectForKey:@"user"] objectForKey:@"id"], nil];
    }
    return _atUrns;
}

- (NSMutableArray *)prizeUids
{
    if (_prizeUids == nil) {
        _prizeUids = [[NSMutableArray alloc] init];

        for (NSMutableDictionary *e in [self.curCollection objectForKey:@"thanks"]) {
            
            [_prizeUids addObject:[e objectForKey:@"id"]];
        }
    }
    
    return _prizeUids;
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
    
    [self grapLoudDetail];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // common variables
    //UIColor *bgColor = [UIColor colorWithRed:245/255.0 green:243/255.0 blue:241/255.0 alpha:1.0];
    UIColor *smallFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:151/225.0 alpha:1.0];
   
    NSDictionary *user = [self.loudDetail objectForKey:@"user"];
    // common variables - check is owner
    isOwner = [[ProfileManager sharedInstance].profile.urn isEqual:[user objectForKey:@"id"]];
    
    // navigation bar title
    self.navigationItem.titleView = [[[NavTitleLabel alloc] 
                                     initWithTitle:[NSString stringWithFormat:@"%@的求助", isOwner ? @"我" :[user objectForKey:@"name"]]] 
                                     autorelease];
    
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] 
                                              initBackBarButtonItemWithTarget:self 
                                              action:@selector(backAction:)] autorelease];
    if (isOwner){
        self.navigationItem.rightBarButtonItem = [[[CustomBarButtonItem alloc] 
                                                   initDelBarButtonItemWithTarget:self action:@selector(delAction:)] autorelease];
    }
    

    self.toHelpNumIndicator.text = [[user objectForKey:@"help_num"] description];
    self.starNumIndicator.text = [[user objectForKey:@"star_num"] description];
    
    self.name.text = [user objectForKey:@"name"];
    [self.avatarImage loadImage:[user objectForKey:@"avatar_link"]];
    
    if (isOwner){
        self.myView.hidden = NO;
    } else{
        self.otherUserView.hidden = NO;
    }
    
    // conetent  put below in table header view
    
    NSString *content;
    if ([[self.loudDetail objectForKey:@"poi"] isEqualToString:@""]) {
        content = [self.loudDetail objectForKey:@"content"];
    } else {
        content = [NSString stringWithFormat:@"我在这里:#%@#, %@", 
                   [self.loudDetail objectForKey:@"poi"], 
                   [self.loudDetail objectForKey:@"content"] ];
    }
    
    CGSize theSize= [content sizeWithFont:[UIFont systemFontOfSize:TEXTFONTSIZE] 
                                               constrainedToSize:CGSizeMake(TEXTWIDTH, CGFLOAT_MAX) 
                                                   lineBreakMode:UILineBreakModeWordWrap];
    CGFloat contentHeight = theSize.height;
    CGFloat heightForAll = 67 + contentHeight + SMALLFONTSIZE;
    
    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 61, 320, heightForAll)] autorelease];
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    OHAttributedLabel *contentText = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(58,  10, TEXTWIDTH, contentHeight)] autorelease];
    contentText.textAlignment = UITextAlignmentLeft;
    contentText.lineBreakMode = UILineBreakModeCharacterWrap;
    contentText.numberOfLines = 0;
    contentText.font = [UIFont systemFontOfSize:TEXTFONTSIZE];
    contentText.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    contentText.opaque = YES;
    contentText.backgroundColor = [UIColor clearColor];
    contentText.attributedText = [Utils tagContent:content];
    
    [tableHeaderView addSubview:contentText];
    
    // location descrtion
    UILabel *locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(58, 55+contentHeight, 190, SMALLFONTSIZE+2)] autorelease];
    locationLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *locationImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location.png"]] autorelease];
    locationImage.frame = CGRectMake(0, 0, SMALLFONTSIZE-1, SMALLFONTSIZE);
    locationImage.backgroundColor = [UIColor clearColor];
    [locationLabel addSubview:locationImage];
    
    UILabel *locationDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SMALLFONTSIZE+4, 0, 190, SMALLFONTSIZE+2)] autorelease];
    locationDescLabel.textAlignment = UITextAlignmentLeft;
    locationDescLabel.font = [UIFont systemFontOfSize: SMALLFONTSIZE];
    locationDescLabel.textColor = smallFontColor;
    locationDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    locationDescLabel.numberOfLines = 1;
    locationDescLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingNone;
    locationDescLabel.backgroundColor = [UIColor clearColor];
    
    [locationLabel addSubview:locationDescLabel];
    
    [tableHeaderView addSubview:locationLabel];
    if (![[self.loudDetail objectForKey:@"address"] isEqual:@""]) {
        locationDescLabel.text =  [self.loudDetail objectForKey:@"address"];
    }
    
    // loud category color show
    UIImageView *loudCateLabel = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20+contentHeight, 320, 24)] autorelease];
    loudCateLabel.backgroundColor = [UIColor clearColor]; 
    loudCateLabel.opaque = NO;
    
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
    NSDictionary *loudcate = [self.loudCates objectForKey:[self.loudDetail objectForKey:@"category"]];
    NSDictionary *status = [self.statuses objectForKey:[self.loudDetail objectForKey:@"status"]];
    
    if (nil != loudcate){
        loudCateLabel.image = [UIImage imageNamed:[loudcate objectForKey:@"stripPic"]];
        loudCateImage.image = [UIImage imageNamed:[loudcate objectForKey:@"colorPic"]];
    }
    
    if (nil != status){
        payCateImage.image = [UIImage imageNamed:[status objectForKey:@"pic"]];
        payCateDescLabel.text = [NSString stringWithFormat:@"%@【%@】", 
                                      [loudcate objectForKey:@"text"], 
                                      [status objectForKey:@"desc"]
                                      ];
    }
    
    [tableHeaderView addSubview:loudCateLabel];
    [tableHeaderView addSubview:loudCateImage];
    
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
    if ([[self.loudDetail objectForKey:@"reply_num"] intValue] >= 0){
        commentLabel.hidden = NO;
        commentLabel.text = [NSString stringWithFormat:@"%d 条评论", [[self.loudDetail objectForKey:@"reply_num"] intValue]];
        
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
    self.tableView.tableHeaderView = tableHeaderView;
    
    // config the sms send textview
    self.messageView = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/* - 40*/, 320, 40)] autorelease];
    
    CGFloat leftPad = 6;
    CGFloat width = 250;
    if (!isOwner) {
        leftPad = 36;
        width = 220;
        
    }
    
	self.textView = [[[HPGrowingTextView alloc] initWithFrame:CGRectMake(leftPad, 3, width, 40)] autorelease];
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
    
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:self.messageView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[[UIImageView alloc] initWithImage:entryBackground] autorelease];
    entryImageView.frame = CGRectMake(leftPad-1, 0, width+8, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:background] autorelease];
    imageView.frame = CGRectMake(0, 0, self.messageView.frame.size.width, self.messageView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.messageView addSubview:imageView];
    [self.messageView addSubview:self.textView];
    [self.messageView addSubview:entryImageView];
        
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    if (!isOwner) {
        UIButton *hasPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hasPhoneBtn.frame = CGRectMake(6, 8, 22, 24);
        hasPhoneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [hasPhoneBtn setImage:[UIImage imageNamed:@"nophone.png"] forState:UIControlStateNormal];
        [hasPhoneBtn addTarget:self action:@selector(phoneAction:) forControlEvents:UIControlEventTouchUpInside];
        self.phoneButton = hasPhoneBtn;
        [self.messageView addSubview:hasPhoneBtn];
    }
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(self.messageView.frame.size.width - 55, 8, 50, 26);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"发送" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    doneBtn.enabled = NO;
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    self.sendButton = doneBtn;
    
	[self.messageView addSubview:doneBtn];
    self.messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    // loading data 
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] 
                                           initWithFrame:CGRectMake(0.0f, 
                                                                    0.0f - self.tableView.bounds.size.height, 
                                                                    self.view.frame.size.width, 
                                                                    self.tableView.bounds.size.height)
                                           ];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
    //  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    self.placeholderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(14, 9, 50, 16)] autorelease];
    self.placeholderLabel.font = [UIFont systemFontOfSize:16.0];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.text = @"回复";

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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];	
    
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(selectOtherAction:) 
//                                                 name:@"cancelLogin" 
//                                               object:nil];
    


}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:@"cancelLogin" 
//                                                  object:nil];
}

- (void)selectOtherAction:(id)sender
{
    if ([ProfileManager sharedInstance].profile) {
        self.textView.text = nil;
        [self.textView becomeFirstResponder];
        [self growingTextViewDidChange: self.textView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // init the list
//    [self egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)loadReplyList
{
    [UIView animateWithDuration:0.7f animations:^{
        
        self.tableView.contentOffset = CGPointMake(0, -65);
        
    } completion:^(BOOL finished) {
        
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
        
    }];
}

#pragma mark - actions for button


-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)delAction:(id)sender
{
    [self deleteLoud];
}

-(void)userInfoShow
{
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    pvc.userLink = [self.tapUser objectForKey:@"link"];
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
}

-(IBAction)avatarButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSMutableDictionary *user = nil;
    if (button.tag == -1){
        user = [self.loudDetail objectForKey:@"user"];
    } else{
        user = [[self.replies objectAtIndex:button.tag] objectForKey:@"user"];
    }
    self.tapUser = user;
//    NSMutableArray *prizeUids = [self.curCollection objectForKey:@"prizes"];
    if (isOwner && 
        ![[self.tapUser objectForKey:@"id"] isEqual:[[self.loudDetail objectForKey:@"user"] objectForKey:@"id"]] && 
        ![self.prizeUids containsObject:[self.tapUser objectForKey:@"id"]]) {
        
        UIActionSheet *contactSheet = [[UIActionSheet alloc] 
                                       initWithTitle:nil
                                       delegate:self 
                                       cancelButtonTitle:@"取消" 
                                       destructiveButtonTitle:nil 
                                       otherButtonTitles:@"查看个人信息", @"感谢TA", nil];
        
        
        contactSheet.tag = 2;
        [contactSheet showFromTabBar:self.tabBarController.tabBar];
        [contactSheet release];
        
    }else {
        [self userInfoShow];
    }
    
}

-(IBAction)helpDoneAction:(id)sender
{
 // be Done here
    [self updateLoudInfo];
}

-(IBAction)justLookAction:(id)sender
{
    if ([ProfileManager sharedInstance].profile) {
        self.textView.text = nil;
        [self.textView becomeFirstResponder];
        [self growingTextViewDidChange: self.textView];
    } else {
        DoubanAuthViewController  *pvc = [[DoubanAuthViewController alloc] initWithNibName:@"DoubanAuthViewController" 
                                                                                    bundle:nil];
        [self.tabBarController presentModalViewController:pvc animated:YES];
        [pvc release];
    }
    
}

#pragma mark - grap the comments

- (void)grapLoudDetail
{
    NSURL *url = [NSURL URLWithString:self.loudLink];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request signInHeader];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200) {
            NSString *response = [request responseString];
            self.loudDetail = [response JSONValue];
            self.curCollection = [self.loudDetail objectForKey:@"reply_collection"];
            self.replies = [self.curCollection objectForKey:@"replies"];
        } else if ([request responseStatusCode] == 404) {
            [Utils warningNotification:@"信息已删除"];
        } else {
            [Utils warningNotification:@"获取信息失败"];
        }

    }
}

- (void)fetchReplyList
{
    
    NSURL *url = [NSURL URLWithString:[self.curCollection objectForKey:@"link"]];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if (nil != self.etag){
        [request addRequestHeader:@"If-None-Match" value:self.etag];
    }
    //[request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestListDone:)];
    [request setDidFailSelector:@selector(requestListWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)requestListDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        NSString *body = [request responseString];
        
        //NSLog(@"body: %@", body);
        // create the json parser 
        NSMutableDictionary * collection = [body JSONValue];
        
        
        self.curCollection = collection;
        // update this loud comments number
//        [self.loud setValue:[collection objectForKey:@"total"] forKey:@"reply_num"];
        
        
        self.replies = [collection objectForKey:@"replies"];
        self.prizeUids = nil;
        self.etag = [[request responseHeaders] objectForKey:@"Etag"];
        
        // reload the tableview data
        [self.tableView reloadData];
        
        //[[[self.tabBarController.tabBar items] objectAtIndex:0] setBadgeValue:nil ];
//        [self fadeInMsgWithText:@"已更新" rect:CGRectMake(0, 0, 60, 40)];
        
    } else if (304 == code){
        // do nothing
    } else{
        
        [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
        
    }
}

- (void)requestListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request replies list: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

- (void)fetchNextReplyList
{
    if (nil == self.replies || nil == [self.curCollection objectForKey:@"next"]){
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.curCollection objectForKey:@"next"]]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestNextListDone:)];
    [request setDidFailSelector:@selector(requestNextListWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
    
}

- (void)requestNextListDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        
        NSString *body = [request responseString];
        // create the json parser 
        NSMutableDictionary *collection = [body JSONValue];
        
        self.curCollection = collection;
        [self.replies addObjectsFromArray:[collection objectForKey:@"replies"]];
        
        // reload the tableview data
        [self.tableView reloadData];
        
    } else{

        [self fadeOutMsgWithText:@"获取数据失败" rect:CGRectMake(0, 0, 80, 66)];
    }
    
}

- (void)requestNextListWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"request next loud list: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}


- (void)deleteLoud
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.loudDetail objectForKey:@"link"]]];
    [request setDelegate:self];
    [request setRequestMethod:@"DELETE"];
    [request setDidFinishSelector:@selector(requestDeleteLoudDone:)];
    [request setDidFailSelector:@selector(requestDeleteLoudWentWrong:)];
    [request signInHeader];
    [request startAsynchronous];
}

-(void)requestDeleteLoudDone:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        
        [self.loudDetail setValue:@"del" forKey:@"status"];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else{
        
        [self fadeOutMsgWithText:@"删除失败" rect:CGRectMake(0, 0, 80, 66)];
    }
}

-(void)requestDeleteLoudWentWrong:(ASIHTTPRequest *)request
{
    
    NSError *error = [request error];
    NSLog(@"request delete loud: %@", [error localizedDescription]);
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.replies.count + 1;
}

-(UITableViewCell *)createMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moretag"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UILabel *labelNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
    
	if (nil == self.curCollection){
        labelNumber.text = @"正在加载...";
    } else if (nil == [self.curCollection objectForKey:@"next"]){
        labelNumber.text = @"";
    } else {
        labelNumber.text = @"获取更多";
    }
    
	[labelNumber setTag:1];
	labelNumber.backgroundColor = [UIColor clearColor];
	labelNumber.font = [UIFont boldSystemFontOfSize:14];
	[cell.contentView addSubview:labelNumber];
	[labelNumber release];
	
    self.moreCell = cell;
    
    return self.moreCell;
}

- (UITableViewCell *)creatNormalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *reply = [self.replies objectAtIndex:indexPath.row];
    NSDictionary *user = [reply objectForKey:@"user"];
    NSString *lenContent = [NSString stringWithFormat:@"%@: %@", [user objectForKey:@"name"], [reply objectForKey:@"content"]];
    
    static NSString *CellIdentifier;
    CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                                      constrainedToSize:CGSizeMake(228.0f, CGFLOAT_MAX) 
                                                          lineBreakMode:UILineBreakModeWordWrap].height;
    
    CellIdentifier = [NSString stringWithFormat:@"replyEntry:%.0f", contentHeight];
    
    ReplyTableCell *cell = (ReplyTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[[ReplyTableCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:CellIdentifier 
                                              height:contentHeight] autorelease];
    } 
    
    
    [cell.avatarImage loadImage:[user objectForKey:@"avatar_link"]];
    
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(avatarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // content
    cell.contentLabel.text = lenContent;
    
    // star prize

    if ([self.prizeUids containsObject:[[reply objectForKey:@"user"] objectForKey:@"id"]]) {
        cell.starLogo.hidden = NO;
    }else {
        cell.starLogo.hidden = YES;
    }
    
    // show phone logo
    if (1 == [[reply objectForKey:@"has_phone"] intValue]){
        cell.phoneLogo.hidden = NO;
    } else{
        cell.phoneLogo.hidden = YES;
    }
    
    
    // date time
    if (nil == [reply objectForKey:@"createdTime"]){
        [reply setObject:[Utils dateFromISOStr:[reply objectForKey:@"created"]] forKey:@"createdTime"];
    }
    cell.timeLabel.text = [Utils descriptionForTime:[reply objectForKey:@"createdTime"]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.replies count]) {
		return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
	} else {
		return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [indexPath row] * 20;
    if (indexPath.row < [self.replies count]){
        
        NSDictionary *reply = [self.replies objectAtIndex:indexPath.row];
        NSDictionary *user = [reply objectForKey:@"user"];
        NSString *lenContent = [NSString stringWithFormat:@"%@: %@", [user objectForKey:@"name"], [reply objectForKey:@"content"]];
        
        CGFloat contentHeight= [lenContent sizeWithFont:[UIFont systemFontOfSize:14.0f] 
                                      constrainedToSize:CGSizeMake(228.0f, CGFLOAT_MAX) 
                                          lineBreakMode:UILineBreakModeWordWrap].height;
        
        return contentHeight + 55;
    } else{
        
        return 40.0f;
    }
}

- (void)loadNextReplyList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.
    
    [self fetchNextReplyList];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (nil != self.curCollection && 
        indexPath.row == [self.replies count] && 
        nil != [self.curCollection objectForKey:@"next"]) 
    {
        
        [self performSelector:@selector(loadNextReplyList) withObject:nil afterDelay:0.2];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.row < [self.replies count]) {
        if ([ProfileManager sharedInstance].profile) {
            if (![[self.loudDetail objectForKey:@"status"] isEqualToString:@"close"]){
                
                NSMutableDictionary *reply = [self.replies objectAtIndex:indexPath.row];
                NSMutableDictionary *user= [reply objectForKey:@"user"];
                if (isOwner && 1 == [[reply objectForKey:@"is_help"] intValue]){
                    // contact the loud's owner.
                    UIDevice *device = [UIDevice currentDevice];
                    UIActionSheet *contactSheet = nil;
                    if ([[device model] isEqualToString:@"iPhone"] ) {
                        
                        contactSheet = [[UIActionSheet alloc] 
                                        initWithTitle:nil
                                        delegate:self 
                                        cancelButtonTitle:@"取消" 
                                        destructiveButtonTitle:nil 
                                        otherButtonTitles:@"电话", @"短信", @"回复", nil];
                    } else {
                        
                        contactSheet = [[UIActionSheet alloc] 
                                        initWithTitle:[NSString stringWithFormat:@"%@: %@", @"联系", [user objectForKey:@"phone"]]
                                        delegate:self 
                                        cancelButtonTitle:@"取消" 
                                        destructiveButtonTitle:nil 
                                        otherButtonTitles:@"回复", nil];
                    }
                    
                    contactSheet.tag = 1;
                    [contactSheet showFromTabBar:self.tabBarController.tabBar];
                    [contactSheet release];
                    
                    self.tapUser = user;
                } else{
                    
                    self.textView.text = [NSString stringWithFormat:@"@%@ ", [user objectForKey:@"name"]];
                    [self.atUrns addObject:[user objectForKey:@"id"]];
                    [self.textView becomeFirstResponder];
                    [self growingTextViewDidChange: self.textView];
                }
                
                
            } else {
                [Utils warningNotification:@"求助已关闭"];
            }
        } else {
            DoubanAuthViewController *pvc = [[DoubanAuthViewController alloc] initWithNibName:@"DoubanAuthViewController" 
                                                                                       bundle:nil];
            [self.tabBarController presentModalViewController:pvc animated:YES];
            [pvc release];
        } 

    }
        

}

#pragma mark - actionsheetp delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    
    if (actionSheet.tag == 1) {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] && buttonIndex < 2) {
            NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", 
                                                   buttonIndex == 0 ? @"tel" : @"sms", 
                                                   [self.tapUser objectForKey:@"phone"]]
                              ];
            
            [[UIApplication sharedApplication] openURL:callURL];
        } else{
            
            self.textView.text = [NSString stringWithFormat:@"@%@ ", [self.tapUser objectForKey:@"name"]];
            [self.atUrns addObject:[self.tapUser objectForKey:@"id"]];
            [self.textView becomeFirstResponder];
            [self growingTextViewDidChange: self.textView];
            
        }
        
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [self userInfoShow];
        } else if (buttonIndex == 1) {
            [self sendPrizePost];
        }
    }  
    
}

- (void)sendPrizePost
{
    
    //[self.loadingIndicator startAnimating];
    
    NSDictionary *prePost = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.loudDetail objectForKey:@"id"], @"loud_urn",
                             [self.tapUser objectForKey:@"id"], @"user_urn",
                             self.tapUser, @"user",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, PRIZEURI]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[prePost JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"POST"];
    // sign to header for authorize
    [request  setDidFinishSelector:@selector(prizeRequestFinished:)];
    [request setDidFailSelector:@selector(prizeRequestFailed:)];
    [request signInHeader];
    [request setDelegate:self];
    
    [request startAsynchronous];
}


- (void)prizeRequestFinished:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (200 == code){
        
//        [self fadeInMsgWithText:@"感谢成功" rect:CGRectMake(0, 0, 80, 66)];
        [self fetchReplyList];
        
    } else {
        
         [Utils warningNotification:@"操作失败"];
        
    }
    
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}


- (void)prizeRequestFailed:(ASIHTTPRequest *)request
{
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    [self fetchReplyList];
    // some more actions here TODO
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (BOOL)hidesBottomBarWhenPushed
{ 
    return TRUE; 
}

#pragma mark - sms text send 
-(void)sendText:(id)sender
{
//    NSLog(@"sent now");
    [self sendPost];

}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.messageView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.messageView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.messageView.frame;
//    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    containerFrame.origin.y = self.view.frame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.messageView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.messageView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.messageView.frame = r;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.textView resignFirstResponder];
}


-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    NSInteger nonSpaceTextLength = [[growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if([growingTextView hasText] && nonSpaceTextLength > 0) {

        self.sendButton.enabled = YES;
        [self.placeholderLabel removeFromSuperview];
        
    } else {
        self.sendButton.enabled = NO;
        [growingTextView addSubview:self.placeholderLabel];

    }
}

-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    if (![growingTextView hasText]) {
        [growingTextView addSubview:self.placeholderLabel];
    } else {
        [self.placeholderLabel removeFromSuperview];
    }
    
}

#pragma mark - set phone number

-(void)phoneAction:(id)sender
{
    UIButton *phoneBtn = (UIButton *)sender;
    if (hasPhone){
        hasPhone = NO;
        [phoneBtn setImage:[UIImage imageNamed:@"nophone.png"] forState:UIControlStateNormal];
    } else{
        if ([ProfileManager sharedInstance].profile.phone == nil){
            //            [Utils warningNotification:@"在关于我中设置你的号码"];
            DDAlertPrompt *loginPrompt = [[DDAlertPrompt alloc] initWithTitle:nil 
                                                                     delegate:self 
                                                            cancelButtonTitle:@"取消" 
                                                             otherButtonTitle:@"确定"];	
            [loginPrompt show];
            [loginPrompt release];
            
        } else{
            hasPhone = YES;
            [phoneBtn setImage:[UIImage imageNamed:@"havephone.png"] forState:UIControlStateNormal]; 
        }
        
    }
    
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
		DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
		[loginPrompt.plainTextField becomeFirstResponder];		
		[loginPrompt setNeedsLayout];
	}
}

-(BOOL)testPhoneNumber:(NSString *)num
{
    NSString *decimalRegex = @"^([0-9]{11})|(([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})|([0-9]{4}|[0-9]{3})-([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1})|([0-9]{7,8})-([0-9]{4}|[0-9]{3}|[0-9]{2}|[0-9]{1}))$";
    NSPredicate *decimalTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    return [decimalTest evaluateWithObject:num];
}

- (void)updateUserInfo
{
    
    NSDictionary *preInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [self.tmpPhoneNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"phone",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[ProfileManager sharedInstance].profile.link];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[preInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"PUT"];
    // sign to header for authorize
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(pRequestFinished:)];
    [request setDidFailSelector:@selector(pRequestFailed:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)pRequestFinished:(ASIHTTPRequest *)request
{
    
    if ([request responseStatusCode] == 200){
        
        // update profile
        [ProfileManager sharedInstance].profile.phone = self.tmpPhoneNum;
        hasPhone = YES;
        [self.phoneButton setImage:[UIImage imageNamed:@"havephone.png"] forState:UIControlStateNormal];
        
    } else{
        
        [Utils warningNotification:@"设置失败"];
    }
    
    
}

- (void)pRequestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}


#pragma mark - done the help
- (void)updateLoudInfo
{
    
    NSDictionary *preInfo = [NSDictionary  dictionaryWithObjectsAndKeys:
                             @"close", @"status",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[self.loudDetail objectForKey:@"link"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request appendPostData:[[preInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"PUT"];
    // sign to header for authorize
    
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(loudUpdateRequestFinished:)];
    [request setDidFailSelector:@selector(loudUpdateRequestFailed:)];
    [request signInHeader];
    [request startAsynchronous];
}

- (void)loudUpdateRequestFinished:(ASIHTTPRequest *)request
{
    
    if ([request responseStatusCode] == 200){
        
        // update profile
//        [self.loud setObject:@"close" forKey:@"status"];
//        [self.navigationController popViewControllerAnimated:YES];
        [self fadeInMsgWithText:@"已关闭" rect:CGRectMake(0, 0, 80, 66)];
        
    } else{

        [self fadeOutMsgWithText:@"设置失败" rect:CGRectMake(0, 0, 80, 66)];
    }
    
    
}

- (void)loudUpdateRequestFailed:(ASIHTTPRequest *)request
{
    // notify the user
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66)];
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView cancelButtonIndex]) {
	} else {
		if ([alertView isKindOfClass:[DDAlertPrompt class]]) {
			DDAlertPrompt *loginPrompt = (DDAlertPrompt *)alertView;
            if (![loginPrompt.plainTextField.text isEqualToString:@""] && ![self testPhoneNumber:loginPrompt.plainTextField.text]) {
                
                [Utils warningNotification:@"无效号码"];
                
            } else{
                self.tmpPhoneNum = loginPrompt.plainTextField.text;
                [self updateUserInfo];
            }
			
		}
	}
}

#pragma mark send post
#pragma mark - send post

- (void)sendPost
{
//    NSLog(@"urns: %@", self.atUrns);
    NSDictionary *prePost = [NSDictionary  dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool: hasPhone], @"has_phone",
                             [self.loudDetail objectForKey:@"id"], @"loud_urn",
                             [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], @"content",
                             self.atUrns, @"ats",
                             nil];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"%@%@", HOST, REPLYURI]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request appendPostData:[[prePost JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addRequestHeader:@"Content-Type" value:@"Application/json;charset=utf-8"];
    [request setRequestMethod:@"POST"];
    // sign to header for authorize
    [request signInHeader];
    [request setDelegate:self];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSInteger code = [request responseStatusCode];
    if (201 == code){
        
        self.atUrns = nil;
        [self.textView resignFirstResponder];
//        [self fadeInMsgWithText:@"回复成功" rect:CGRectMake(0, 0, 80, 66)];
//        [self fetchReplyList]; // TODO 
        [self loadReplyList];
        
    } else{
        
//        [self fadeOutMsgWithText:@"发送失败" rect:CGRectMake(0, 0, 80, 66)];
        [self fadeOutMsgWithText:@"发送失败" rect:CGRectMake(0, 0, 80, 66) offSetY:90];
        
    }
    
    self.sendButton.enabled = YES;
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    [self fadeOutMsgWithText:@"网络链接错误" rect:CGRectMake(0, 0, 80, 66) offSetY:90];
    self.sendButton.enabled = YES;
    
}
@end
