//
//  HelpPostViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpPostViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    NSArray *helpCategories_;
}

@property (nonatomic, retain, readonly) NSArray *helpCategories;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
