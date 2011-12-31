//
//  NSDate+IsoFormat.h
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (IsoFormat)

+(NSString *) strFromISO8601:(NSDate *) date;
+(NSDate *) dateFromISO8601:(NSString *) str;
+(NSDate *)moveDateToZTimezone:(NSDate *)sourceDate;

@end
