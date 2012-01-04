//
//  UserManager.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
{
@private
    NSMutableDictionary *userCache_;
    NSMutableDictionary *photoCache_;
    NSOperationQueue *queue_;
    
}

@property (nonatomic, retain) NSMutableDictionary *userCache, *photoCache;
@property (nonatomic, retain, readonly) NSOperationQueue *queue;


- (void)removePhotoCacheForSpaceCost;
- (void)removeUserCacheForSpaceCost;
- (void)fetchPhotoRequestWithLink:(NSDictionary *)userLink forBlock:(void (^)(NSData *))callback;
- (void)fetchUserRequestWithLink:(NSDictionary *)userLink forBlock:(void (^)(NSDictionary *))callback;

+ (UserManager *)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (oneway void)release;
- (id)autorelease;

@end
