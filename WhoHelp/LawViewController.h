//
//  LawViewController.h
//  WhoHelp
//
//  Created by cloud on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LawViewController : UIViewController
{
@private
    UITextView *content_;
}

@property (nonatomic, retain) IBOutlet UITextView *content;

- (IBAction)cancelButtonPressed:(id)sender;

@end
