//
//  Profile.h
//  WhoHelp
//
//  Created by cloud on 11-9-11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * phone;
@property (nonatomic, retain) NSNumber * isLogin;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSNumber * lastLon;
@property (nonatomic, retain) NSNumber * lastLat;
@property (nonatomic, retain) NSNumber * loudNum;
@property (nonatomic, retain) NSDate * updated;

@end
