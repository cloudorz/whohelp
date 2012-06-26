//
//  ProfileManager.h
//  WhoHelp
//
//  Created by cloud on 11-10-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"
#import "Device.h"

@interface ProfileManager : NSObject

@property (nonatomic, strong) Profile *profile;
@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) Device *device; 

+ (ProfileManager *)sharedInstance;

- (void)save;
- (void)del;
//- (NSManagedObject *)getProfileByKey:(NSString *)key;
- (void)saveUserInfo:(NSMutableDictionary *) data;
//- (void)logout;

@end
