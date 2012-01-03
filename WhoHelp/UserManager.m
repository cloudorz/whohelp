//
//  UserManager.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "Config.h"
#import "SBJson.h"

static UserManager *sharedUserManager = nil;

@implementation UserManager

@synthesize userCache=userCache_;
@synthesize photoCache=photoCache_;

-(void) dealloc
{
    [userCache_ release];
    [photoCache_ release];
    [queue_ release];
    [super dealloc];
}

-(NSOperationQueue *)queue
{
    if (queue_ == nil){
        queue_ = [[NSOperationQueue alloc] init];
    }
    
    return queue_;
}

- (id)init
{
    self = [super init];
    if (nil != self){
        // do some thing here
        self.userCache = [[NSMutableDictionary alloc] init];
        self.photoCache =  [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


// do some thing here
- (void)removeUserCacheForSpaceCost
{
    if (self.userCache == nil || self.userCache.count < 350) return;
    
    NSArray *sortedKeys = [self.userCache keysSortedByValueUsingComparator:^(NSDictionary *k1, NSDictionary *k2){
        NSDate *d1 = [k1 objectForKey:@"expired"];
        NSDate *d2 = [k2 objectForKey:@"expired"];
        //return [d1 compare:d2]; // asc
        return [d2 compare:d1]; // desc
    }];
    NSArray *willCutKeys = [sortedKeys subarrayWithRange:NSMakeRange(300, sortedKeys.count - 300)];
    [self.userCache removeObjectsForKeys:willCutKeys];
}

- (void)removePhotoCacheForSpaceCost
{
    if (self.photoCache == nil || self.photoCache.count < 350) return;
    
    NSArray *sortedKeys = [self.photoCache keysSortedByValueUsingComparator:^(NSDictionary *k1, NSDictionary *k2){
        NSDate *d1 = [k1 objectForKey:@"expired"];
        NSDate *d2 = [k2 objectForKey:@"expired"];
        //return [d1 compare:d2]; // asc
        return [d2 compare:d1]; // desc
    }];
    NSArray *willCutKeys = [sortedKeys subarrayWithRange:NSMakeRange(300, sortedKeys.count - 300)];
    [self.photoCache removeObjectsForKeys:willCutKeys];
}

- (void)fetchPhotoRequestWithUserId:(NSString *)uid withImgURL:(NSString *)urlString forBlock:(void (^)(NSData *))callback
{
    __block NSMutableDictionary *info = [self.photoCache objectForKey:uid];
    
    if (nil == info){
        info = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    if (nil != [info objectForKey:@"expired"] && abs([[info objectForKey:@"expired"] timeIntervalSinceNow]) < 6*60){
        // perform the selector which can use avatar to do something.
        callback([info objectForKey:@"avatar"]);
        
    } else{
    
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        if (nil != [info objectForKey:@"last"]){
            [request addRequestHeader:@"If-Modified-Since" value:[info objectForKey:@"last"]];
        }
        
        [request setCompletionBlock:^{
            // Use when fetching text data
            
            NSInteger code = [request responseStatusCode];
            
            if (304 == code || 200 == code){
                if (200 == code){
                    // create new element of the cache 
                    // remove the old old ones
                    [self removePhotoCacheForSpaceCost];
                    // set the new avatar data
                    [info setObject:[request responseData] forKey:@"avatar"];
                }
                [info setObject: [[request responseHeaders] objectForKey:@"Last-Modified"] forKey:@"last"];
                [info setObject:[NSDate date] forKey:@"exipred"];
                [self.photoCache setObject:info forKey:uid];
                
                callback([info objectForKey:@"avatar"]);
            }
            
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"%@", [error localizedDescription]);
            // do nothing
        }];
        
        [self.queue addOperation:request];
    }
}

- (void)fetchUserRequestWithLink:(NSDictionary *)userLink forBlock:(void (^)(NSDictionary *))callback
{
    NSString *uid = [userLink objectForKey:@"id"];
    NSString *urlString = [userLink objectForKey:@"link"];
    
    __block NSMutableDictionary *info = [self.userCache objectForKey:uid];
    
    if (nil == info){
        info = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    if (nil != [info objectForKey:@"expired"] && abs([[info objectForKey:@"expired"] timeIntervalSinceNow]) < 6*60){
        // perform the selector which can use avatar to do something.
        callback(info);
        
    } else{
        
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        if (nil != [info objectForKey:@"last"]){
            [request addRequestHeader:@"If-Modified-Since" value:[info objectForKey:@"last"]];
        }
        
        [request setCompletionBlock:^{
            // Use when fetching text data
            
            NSInteger code = [request responseStatusCode];
            
            if (304 == code || 200 == code){
                if (200 == code){
                    // create new element of the cache 
                    // remove the old old ones
                    [self removeUserCacheForSpaceCost];
                    // set the new avatar data
                    info = [[request responseString] JSONValue];
                }
                [info setObject: [[request responseHeaders] objectForKey:@"Last-Modified"] forKey:@"last"];
                [info setObject:[NSDate date] forKey:@"exipred"];
                [self.userCache setObject:info forKey:uid];
                
                callback(info);
            }
            
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"%@", [error localizedDescription]);
            // do nothing
        }];
        
        [self.queue addOperation:request];
    }
}


// for singleton

+ (UserManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedUserManager == nil) {
            [[self alloc] init];
        }
    }
    return sharedUserManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedUserManager == nil) {
            sharedUserManager = [super allocWithZone:zone];
            return sharedUserManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


@end
