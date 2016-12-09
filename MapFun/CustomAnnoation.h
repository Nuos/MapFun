//
//  CustomAnnoation.h
//  MapFun
//
//  Created by yxhe on 16/12/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//
// ---- 自定义大头针 ---- //


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnoation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate; // 坐标
@property (nonatomic, copy) NSString *title;    // 主标题
@property (nonatomic, copy) NSString *subtitle; // 副标题
@property (nonatomic, strong) UIImage *image; // 图片

@end
