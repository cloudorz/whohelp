//
//  WhoHelpAppDelegate.h
//  WhoHelp
//
//  Created by cloud on 11-9-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface WhoHelpAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
@private
    UITabBarController *tabBarController_;
    Profile *profile_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, readonly) Profile *profile;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
