//
//  Config.h
//  WhoHelp
//
//  Created by cloud on 11-9-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef WhoHelp_Config_h
#define WhoHelp_Config_h

// new
#define HOST @"http://i.n2u.in"
#define APPKEY @"apple2011122801"
#define SECRET @"3afb9fb7f605476d92b9ee7000b41ba0"
#define LOUDURI @"/l/"
#define LOUDSEARCH @"/s"
#define USERURI @"/u/"
#define REPLYURI @"/reply/"
#define PRIZEURI @"/prize/"
#define USERLISTURI @"/offer-help-users/"
#define UPLOADURI @"/upload"
#define MSGURI @"/msg/"
#define ULOUDURI @"/loudupdate"
#define UMSGURI @"/msgupdate"
#define UPRIZEURI @"/prizeupdate"
#define DDURI @"/device/"

#define TEXTWIDTH 246.0f

#define NAMEFONTSIZE 14.0f
#define SMALLFONTSIZE 9.0f
#define TEXTFONTSIZE 15.0f

// cache time
#define PHOTODUE 6*60
#define USERDUE 60

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif

