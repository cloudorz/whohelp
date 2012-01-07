//
//  TopLine.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopLine.h"

@implementation TopLine

-(id)initWithDefault
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 5)];
    if (self != nil){
        self.image = [UIImage imageNamed:@"tableheader.png"];
        self.opaque = YES;
    }
    
    return self;
}

@end
