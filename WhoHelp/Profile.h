//
//  Profile.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * avatar_link;
@property (nonatomic, retain) NSString * brief;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * urn;
@property (nonatomic, retain) NSString * userkey;

@end
