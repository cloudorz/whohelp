//
//  ProfileManager.h
//  WhoHelp
//
//  Created by cloud on 11-10-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@interface ProfileManager : NSObject
{
    Profile *profile_;
    NSManagedObjectContext *moc_;
}

@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSManagedObjectContext *moc;

+ (ProfileManager *)sharedInstance;

- (void)save;
//- (void)del;
- (NSManagedObject *)getProfileByKey:(NSString *)key;
- (void)saveUserInfo:(NSMutableDictionary *) data;
//- (void)logout;

@end
