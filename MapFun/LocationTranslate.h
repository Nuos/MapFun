//
//  LocationTranslate.h
//  MapFun
//
//  Created by yxhe on 16/12/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationTranslate : NSObject

// 判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

// 转GCJ-02
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end

