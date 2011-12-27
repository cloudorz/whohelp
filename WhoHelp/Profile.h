//
//  Profile.h
//  WhoHelp
//
//  Created by cloud on 11-9-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userkey;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSDate * updated;

@end
