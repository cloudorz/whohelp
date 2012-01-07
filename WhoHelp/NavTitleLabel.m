//
//  NavTitleLabel.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NavTitleLabel.h"

@implementation NavTitleLabel

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithFrame:CGRectMake(50, 5, 220, 30)];
    if (nil != self){
        self.textAlignment = UITextAlignmentCenter;
        self.text = title;
        self.font = [UIFont boldSystemFontOfSize:18.0f];
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


@end
