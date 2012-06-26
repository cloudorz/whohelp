//
//  HZAnnotation.h
//  WhoHelp
//
//  Created by Dai Cloud on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HZAnnotation : NSObject <MKAnnotation>

// pin's coordinates (only required property)
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
// pin's title
@property (nonatomic, copy) NSString *title;
// pin's subtitle
@property (nonatomic, copy) NSString *subtitle;


@end
