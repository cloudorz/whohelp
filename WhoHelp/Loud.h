//
//  Loud.h
//  WhoHelp
//
//  Created by cloud on 11-9-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Loud : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lid;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSData * userAvatar;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * userPhone;

@end
