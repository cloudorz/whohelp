//
//  DetailLoudViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailLoudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    NSDictionary *loud_;
}

@property (nonatomic, retain) NSDictionary *loud;

@end
