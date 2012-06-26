//
//  WhoHelpAppDelegate.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iVersion.h"

@interface WhoHelpAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, iVersionDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet UITabBarItem *nearbyItem, *myListItem, *helpItem, *settingItem;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
