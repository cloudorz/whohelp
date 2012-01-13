//
//  AuthPageViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthPageViewController : UIViewController <UIWebViewDelegate>
{
@private
    UIWebView *webview_;
    UIActivityIndicatorView *loading_;
    NSString *body_;
    NSURL *baseURL_;
}

@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSURL *baseURL;

@end
