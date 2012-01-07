//
//  CustomBarButtonItem.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarButtonItem : UIBarButtonItem

-(id)initBackBarButtonItemWithTarget:(id)target action:(SEL)action;
-(id)initSendBarButtonItemWithTarget:(id)target action:(SEL)action;
-(id)initDelBarButtonItemWithTarget:(id)target action:(SEL)action;

@end
