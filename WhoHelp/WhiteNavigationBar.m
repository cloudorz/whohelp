//
//  WhiteNavigationBar.m
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WhiteNavigationBar.h"

@implementation WhiteNavigationBar

- (void)drawRect:(CGRect)rect {
    UIImage *image;
    /*if([[dataEngine GetInstance] gethome])
     image= [UIImage imageNamed: @"topx.png"];
     else 
     */
    image= [UIImage imageNamed: @"navheader.png"];
    [image drawInRect:rect];
}

// TODO custom whole bar items

@end
