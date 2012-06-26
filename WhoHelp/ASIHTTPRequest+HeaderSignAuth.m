//
//  ASIHTTPRequest+HeaderSignAuth.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest+HeaderSignAuth.h"
#import "ProfileManager.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "NSString+URLEncoding.h"

@implementation ASIHTTPRequest (HeaderSignAuth)

- (NSDictionary *)getAppKeyAndSecret
{
    return [NSDictionary dictionaryWithObjectsAndKeys:APPKEY, @"key", 
                                               SECRET, @"secret", 
     nil];
}

- (NSDictionary *)getUserKeyAndSecret
{
    
    return [NSDictionary dictionaryWithObjectsAndKeys: [ProfileManager sharedInstance].profile.userkey, @"key", 
                                                       [ProfileManager sharedInstance].profile.secret, @"secret", 
            nil];
}

- (NSString *)getOnce: (NSInteger)len
{
    //NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *letters = @"0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
    }
    
    return randomString;
    
}

- (NSDictionary *)getAuthParameters
{
    // auth_app_key auth_user_key auth_once auth_timestamp auth_signature_method
    return [NSDictionary dictionaryWithObjectsAndKeys:
     [[self getAppKeyAndSecret] objectForKey:@"key"], @"auth_app_key",
     [[self getUserKeyAndSecret] objectForKey:@"key"], @"auth_user_key",
     [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], @"auth_timestamp",
     [self getOnce:8], @"auth_once",
     @"HMAC-SHA1", @"auth_signature_method",
     nil];
}

- (NSString *)getNormalizedMethd
{

    return [self.requestMethod uppercaseString];

}

- (NSString *)getNormalizedURL
{

    return [[[self.url description] componentsSeparatedByString:@"?"] objectAtIndex:0];
}

- (NSString *)getNormalizedArgs: (NSDictionary *)authArgs
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:authArgs];

    NSString *queryStr = [self.url query];
    if (nil != queryStr){
        NSMutableString *query = [NSMutableString stringWithString:queryStr];
        [query replaceOccurrencesOfString:@"+" 
                               withString:@" " 
                                  options:NSLiteralSearch 
                                    range:NSMakeRange(0, [query length])];
        
        NSArray *argsPair = [query componentsSeparatedByString:@"&"];
        if (argsPair != nil){
            for (NSString *e in argsPair) {
                NSArray *items = [e componentsSeparatedByString:@"="];
                if (nil == [args objectForKey:[items objectAtIndex:0]]){
                    // a=1&a=2 like this query string, get the a=1, cut a=2...
                    [args setObject:[[items objectAtIndex:1] URLDecodedString] 
                             forKey:[[items objectAtIndex:0] URLDecodedString]
                     ];
                }

                // FIXME bug# first sort by key, then by value. for two same key
            }
        }
    }
    
    // sorted
    NSArray *sortedKeys = [[args allKeys] sortedArrayUsingComparator:^(NSString *k1, NSString *k2){
        return [k1 compare:k2];
    }];
    
    NSMutableArray *keyAndValuePairs = [NSMutableArray arrayWithCapacity:5];
    for (NSString *key in sortedKeys) {
        [keyAndValuePairs addObject:[NSString stringWithFormat:@"%@=%@", 
                                      [key URLEncodedString], 
                                      [[[args objectForKey:key] description] URLEncodedString]
                                      ]];
    }

    NSString *res = [keyAndValuePairs componentsJoinedByString:@"&"];

    return res;
}

- (NSString *)signatureWithArgs: (NSDictionary *)authArgs
{
    NSArray *sig = [NSArray arrayWithObjects:
                    [[self getNormalizedMethd] URLEncodedString], 
                    [[self getNormalizedURL] URLEncodedString], 
                    [[self getNormalizedArgs:authArgs] URLEncodedString], 
                    nil];
    NSArray *keys = [NSArray arrayWithObjects:
                     [[[self getAppKeyAndSecret] objectForKey:@"secret"] URLEncodedString], 
                     [[[self getUserKeyAndSecret] objectForKey:@"secret"] URLEncodedString],
                     nil];
    
    NSString *key = [keys componentsJoinedByString:@"&"];
    NSString *raw = [sig componentsJoinedByString:@"&"];
    
    OAHMAC_SHA1SignatureProvider *hmac = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *res = [hmac signClearText:raw withSecret:key];
    [hmac release];
    
    return res;
}

- (void)signInHeader
{
    NSDictionary *preAuthArgs = [self getAuthParameters];
    NSMutableDictionary *authArgs = [NSMutableDictionary dictionaryWithDictionary:preAuthArgs];
    [authArgs setObject:[self signatureWithArgs:preAuthArgs] forKey:@"auth_signature"];
    
    NSMutableString *authHeader = [NSMutableString stringWithString:@"Auth realm=\"http://whohelp.me\""];
    for (NSString *key in [authArgs keyEnumerator]) {
        [authHeader appendFormat:@", %@=\"%@\"", key, [authArgs objectForKey:key]];
    }
    
    [self addRequestHeader:@"Authorization" value:authHeader];
}

@end
