//
//  DoubanAuthViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubanAuthViewController : UIViewController <UIWebViewDelegate>
{
@private
    IBOutlet UIWebView *webview_;
    IBOutlet UIActivityIndicatorView *loading_;
    NSString *body_;
    NSURL *baseURL_;
}

@property (nonatomic, retain) UIWebView *webview;
@property (nonatomic, retain) UIActivityIndicatorView *loading;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSURL *baseURL;

@end
