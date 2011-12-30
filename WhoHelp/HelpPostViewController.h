//
//  HelpPostViewController.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpPostViewController : UITableViewController
{
@private
    NSArray *helpCategories_;
}

@property (nonatomic, retain, readonly) NSArray *helpCategories;

@end
