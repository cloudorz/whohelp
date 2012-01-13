//
//  Profile.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject

@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSString * brief;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * urn;
@property (nonatomic, retain) NSString * userkey;
@property (nonatomic, retain) NSString * weibo;
@property (nonatomic, retain) NSString * douban;
@property (nonatomic, retain) NSString * renren;

@end
