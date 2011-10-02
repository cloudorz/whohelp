//
//  Utils.m
//  WhoHelp
//
//  Created by cloud on 11-9-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "ASIHTTPRequest.h"
#import "Config.h"

@implementation Utils

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - handling errors
+ (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message
{
    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [Notpermitted show];
    [Notpermitted release];
}

+ (void)warningNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"警告" forMessage:message];
}

+ (void)errorNotification:(NSString *)message
{
    [self helpNotificationForTitle:@"错误" forMessage:message];  
}

#pragma mark - date formate to human readable
+ (NSString *)descriptionForTime:(NSDate *)date
{
    // convert the time formate to human reading. 
    NSInteger timePassed = abs([date timeIntervalSinceNow]);
    
    NSString *dateString = nil;
    if (timePassed < 60){
        dateString = [NSString stringWithFormat:@"%d秒前", timePassed];
    }else{
        if (timePassed < 60*60){
            dateString = [NSString stringWithFormat:@"%d分钟前", timePassed/60];
        }else{
            NSDateFormatter *dateFormat = [NSDateFormatter alloc];
            [dateFormat setLocale:[NSLocale currentLocale]];
            NSString *dateFormatString = nil;
            NSDateComponents *curDateComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
            NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            if (timePassed < 24*60*60 && curDateComp.day == dateComp.day ){
                dateFormatString = [NSString stringWithFormat:@"今天 %@", [NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]]];
            }else{
                dateFormatString = [NSDateFormatter dateFormatFromTemplate:@"MM-dd HH:mm" options:0 locale:[NSLocale currentLocale]];
            }
            [dateFormat setDateFormat:dateFormatString];
            dateString = [dateFormat stringFromDate:date];
        }
    }
    return dateString;
}

#pragma mark - string to datetime
+ (NSDate *)stringToTime:(NSString *)stringTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate * date = [dateFormatter dateFromString:stringTime];
    [dateFormatter release];
    return date;
}

#pragma mark - get the images
+ (NSData *)fetchImage: (NSString *)imageURI
{
    NSURL *url = [NSURL URLWithString:imageURI];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error && (200 == [request responseStatusCode] || 304 == [request responseStatusCode])) {
        
        return [request responseData];
    }
    
    return nil;
}

#pragma makr link the part uri with query string
+ (NSURL *)partURI: (NSString *)uri queryString: (NSString *) query
{
   
    NSString *fill = [[NSString alloc] init];
    
    NSRange rang = [uri rangeOfString:@"?" options:NSBackwardsSearch];
    if (rang.location != NSNotFound){
        if (rang.location == ([uri length] - 1)){
            fill = @"";
        } else {
            fill = @"&";
        }
    } else{
        fill = @"?";
    }
    
    NSURL *fullURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", uri, fill, query]];
    [fill release];
    
    return fullURI;
}

@end
