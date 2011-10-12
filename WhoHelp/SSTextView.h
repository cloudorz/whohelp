//
//  SSTextView.h
//  WhoHelp
//
//  Created by cloud on 11-10-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTextView : UITextView 
{
    
    NSString *_placeholder;
    UIColor *_placeholderColor;
    
    BOOL _shouldDrawPlaceholder;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

@end
