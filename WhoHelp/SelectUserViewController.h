//
//  SelectUserViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectUserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    UITableView *tableView_;

}

@property (nonatomic, retain) IBOutlet UITableView *tableView;


@end
