//
//  ASIHTTPRequest+HeaderSignAuth.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface ASIHTTPRequest (HeaderSignAuth)

- (NSDictionary *)getAppKeyAndSecret;
- (NSDictionary *)getUserKeyAndSecret;
- (NSString *)getNormalizedMethd;
- (NSString *)getNormalizedURL;
- (NSString *)getNormalizedArgs: (NSDictionary *)authArgs;
- (NSString *)signatureWithArgs: (NSDictionary *)preAuthArgs;
- (void)signInHeader;

@end
