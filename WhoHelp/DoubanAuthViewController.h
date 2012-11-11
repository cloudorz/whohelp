//
//  DoubanAuthViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubanAuthViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webview;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) IBOutlet UINavigationItem *cusNavigationItem;
//@property (nonatomic, strong) NSString *body;
//@property (nonatomic, strong) NSURL *baseURL;

- (IBAction)cancelAuth:(id)sender;
@end
