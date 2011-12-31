//
//  NSDate+ProxyForJson.m
//  WhoHelp
//
//  Created by Dai Cloud on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+ProxyForJson.h"
#import "NSDate+IsoFormat.h"

@implementation NSDate (ProxyForJson)

// just for iso format json nsdate
- (id)proxyForJson
{
    
    return [NSDate strFromISO8601:self];
}

@end
