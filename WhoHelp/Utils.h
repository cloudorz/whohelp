//
//  Utils.h
//  WhoHelp
//
//  Created by cloud on 11-9-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Utils : NSObject

+ (void)helpNotificationForTitle: (NSString *)title forMessage: (NSString *)message;
+ (void)errorNotification:(NSString *)message;
+ (void)warningNotification:(NSString *)message;
+ (void)tellNotification:(NSString *)message;

+ (NSString *)descriptionForTime:(NSDate *)date;
+ (NSDate *)dateFromISOStr:(NSString *)stringTime;
+ (NSData *)fetchImage: (NSString *)imageURI;

+ (NSURL *)partURI: (NSString *)uri queryString: (NSString *) query;
+ (void)uploadImageFromData:(NSData *)avatarData phone:(NSString *)phone;
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;
+ (NSMutableAttributedString *)wrongInfoString: (NSString *)rawString;
+ (NSMutableAttributedString *)colorContent: (NSString *)rawString;
+ (NSString *)genRandStringLength:(int)len;
+ (NSString *)postionInfoFrom: (CLLocation *)curPos toLoud:(NSDictionary *)loud;

@end
