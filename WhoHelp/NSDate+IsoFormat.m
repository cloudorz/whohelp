//
//  NSDate+IsoFormat.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+IsoFormat.h"

#define ISO_TIMEZONE_UTC_FORMAT @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT @"+%f:%f"

@implementation NSDate (IsoFormat)

+(NSString *) strFromISO8601:(NSDate *) date {
    static NSDateFormatter* sISO8601 = nil;
	NSString *datastring = nil;
	if(date != nil) {
		date = [NSDate moveDateToZTimezone:date];
		if (!sISO8601) {
			sISO8601 = [[NSDateFormatter alloc] init];
			NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			[sISO8601 setDateFormat:strFormat];
		}
		datastring = [sISO8601 stringFromDate:date];
	}
	return datastring;
} 

+(NSDate *) dateFromISO8601:(NSString *) str {
    static NSDateFormatter* sISO8601 = nil;
	NSDate *d = nil;
	@try {
		if(str != nil && [str length] > 0) {
			
			if (!sISO8601) {
				sISO8601 = [[NSDateFormatter alloc] init];
				[sISO8601 setTimeStyle:NSDateFormatterFullStyle];
				[sISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
			}
			if ([str hasSuffix:@"Z"]) {
				str = [str stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
			}
			d = [sISO8601 dateFromString:str];
		}
		
	} 
	@catch (id theException) {
		//DLog(@"%@", theException);
	} 
    
	return d;
    
    
}

+(NSDate *)moveDateToZTimezone:(NSDate *)sourceDate {
	
	NSTimeZone* sourceTimeZone = [NSTimeZone systemTimeZone];
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = - sourceGMTOffset;
	
	return [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
    
}
@end