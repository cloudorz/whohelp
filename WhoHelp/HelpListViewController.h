//
//  HelpListViewController.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
@private
    NSFetchedResultsController *resultsController_;
    NSMutableArray *profiles_;
}

@property (nonatomic, readonly) NSFetchedResultsController *resultsController;
@property (nonatomic, retain) NSMutableArray *profiles;

@end
