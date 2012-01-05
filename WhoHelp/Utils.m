//
//  Utils.m
//  WhoHelp
//
//  Created by cloud on 11-9-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSAttributedString+Attributes.h"
#import "Config.h"
#import "NSDate+IsoFormat.h"

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

+ (void)tellNotification:(NSString *)message
{
    [self helpNotificationForTitle:nil forMessage:message];  
}

#pragma mark - date formate to human readable
+ (NSString *)descriptionForTime:(NSDate *)date
{
    // convert the time formate to human reading.
    // i18n FIXME
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
            
            // compare the now and then time.
            NSDateComponents *curDateComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
            NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            
            if (timePassed < 24*60*60 && curDateComp.day == dateComp.day ){
                dateFormatString = [NSString stringWithFormat:@"今天 %@", [NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]]];
            }else{
                dateFormatString = [NSDateFormatter dateFormatFromTemplate:@"M-d H:m" options:0 locale:[NSLocale currentLocale]];
            }
            [dateFormat setDateFormat:dateFormatString];
            dateString = [dateFormat stringFromDate:date];
            
            [dateFormat release];
        }
    }
    return dateString;
}

#pragma mark - string to datetime
+ (NSDate *)dateFromISOStr:(NSString *)stringTime
{
    if ([stringTime characterAtIndex:stringTime.length - 1] != 'Z'){
        stringTime = [NSString stringWithFormat:@"%@Z", stringTime];
    }
    
    return [NSDate dateFromISO8601:stringTime];
}

#pragma mark - get upload the images
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

+ (void)uploadImageFromData:(NSData *)avatarData phone:(NSString *)phone
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?ak=%@", UPLOADURI, APPKEY]]];
    [request setData:avatarData withFileName:[NSString stringWithFormat:@"%@.jpg", phone] andContentType:@"image/jpg" forKey:@"photo"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        if ([request responseStatusCode] == 200){
             // Nothing
        } else if (400 == [request responseStatusCode]){
            [self warningNotification:@"上传头像失败"];
        } else{
            [self warningNotification:@"服务器异常返回"];
        }
        
    }else{
        [self warningNotification:@"请求服务错误"];
    }
}

#pragma makr link the part uri with query string
+ (NSURL *)partURI: (NSString *)uri queryString: (NSString *) query
{
   
    NSString *fill;
    
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

#pragma mark - thumbnail image
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
{
    
    UIImage *newimage;
    
    if (nil == image) {        
        newimage = nil;
    }
    else{
        UIGraphicsBeginImageContext(asize);
        
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return newimage;
    
}

#pragma mark - distance info
+ (NSString *)postionInfoFrom: (CLLocation *)curPos toLoud:(NSDictionary *)loud
{
    
    return [NSString stringWithFormat:@"%@ %.0f米",
     [[loud objectForKey:@"address"] isEqual:[NSNull null]] ? @"" : 
            [loud objectForKey:@"address"],
     [curPos distanceFromLocation:
      [[[CLLocation alloc] initWithLatitude:[[loud objectForKey:@"lat"] doubleValue] longitude:[[loud objectForKey:@"lon"] doubleValue]] autorelease]]
     ];
    
}
#pragma mark - wrong notify
+ (NSMutableAttributedString *)wrongInfoString: (NSString *)rawString
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:rawString];
    [attributedString setFont:[UIFont systemFontOfSize:14.0]];
    [attributedString setTextColor:[UIColor redColor]];
    return attributedString;
}

#pragma mark - color content
+ (NSMutableAttributedString *)colorContent: (NSString *)rawString
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithString:rawString];
    [attributedString setFont:[UIFont systemFontOfSize:14.0]];
    [attributedString setTextColor:[UIColor colorWithRed:119/255.0 green:119/255.0 blue:119/255.0 alpha:1.0]];
    
    NSRange rang = [rawString rangeOfString:@"$" options:NSBackwardsSearch];
    if (NSNotFound != rang.location){
        [attributedString setTextColor:[UIColor colorWithRed:111/255.0 green:195/255.0 blue:58/255.0 alpha:1.0] 
                                 range:NSMakeRange(rang.location, [rawString length] - rang.location)];
    }
    return attributedString;
}


#pragma mark - random number

+ (NSString *)genRandStringLength:(int)len 
{
    //NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *letters = @"0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
    }
    
    return randomString;
    
}

@end
