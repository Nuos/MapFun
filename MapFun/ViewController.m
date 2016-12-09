//
//  ViewController.m
//  MapFun
//
//  Created by yxhe on 16/12/7.
//  Copyright © 2016年 tashaxing. All rights reserved.
//
// ---- 定位，地理编解码，地图（自带高德），导航相关) ---- //

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ViewController.h"
#import "CustomAnnoation.h"
#import "LocationTranslate.h"


@interface ViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocationManager *_locationManager; // 定位管理器
    CLGeocoder *_geocoder; // 地理编解码
    MKMapView *_mapView; // 地图控件
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1，地图
    _mapView = [[MKMapView alloc] init];
    _mapView.frame = CGRectMake(0, 100, self.view.frame.size.width, 400);
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading; // 自动定位和朝向，还有其他枚举,调用地图自带的定位服务
    
    // 添加一个大头针
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(31.239879, 121.499674);
    [self addMapAnnotation:coord withTitle:@"陆家嘴啊" withSubtitle:@"以后能去那工作就好了，加油"];
    
    // 2，定位管理器
    _locationManager = [[CLLocationManager alloc] init];
    
    // 检测定位服务开关
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"请打开定位服务");
        return;
    }
    
    // 用户授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        // 这里只请求在试用期间定位（也可以两种都请求，在设置里面能看到切换）
//        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
    }
    
    // 如果已经打开定位就定位
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        // 开始定位
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 定位精度
        CLLocationDistance distance = 2; // 2米更新一次
        [_locationManager setDistanceFilter:distance]; // 隔多远定位一次
        
    }
    
    // 2， 地理位置编解码
    _geocoder = [[CLGeocoder alloc] init];
    [self getCoordinateByAddress:@"上海"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:39.5 longitude:116.7];
    [self getAddressByLocation:location];
    
}

// 启动定位按钮
- (IBAction)locateBtn:(id)sender
{
    // 启动，更新方向和定位
    [_locationManager startUpdatingHeading];
    [_locationManager startUpdatingLocation];
}

// 停止定位按钮
- (IBAction)stopBtn:(id)sender
{
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
}



#pragma mark - 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // 更新陀螺仪方向
    NSLog(@"%@", newHeading);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations firstObject]; // 取出第一个位置(一系列位置，应该有个范围)
    
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    
    // 如果是国内的坐标就修正
    if (![LocationTranslate isLocationOutOfChina:coordinate])
    {
        coordinate = [LocationTranslate transformFromWGSToGCJ:coordinate];
    }
    
//    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f", coordinate.longitude, coordinate.latitude, location.altitude, location.course, location.speed);
    
    [self getAddressByLocation:location];
    
//    [self addMapAnnotation:coordinate withTitle:@"我的位置" withSubtitle:@"好偏僻啊"];
    
}

#pragma mark - 地图
- (void)addMapAnnotation:(CLLocationCoordinate2D)location2D withTitle:(NSString *)title withSubtitle:(NSString *)subtitle
{
    CustomAnnoation *annotation = [[CustomAnnoation alloc] init];
    annotation.coordinate = location2D;
    annotation.title = title;
    annotation.subtitle = subtitle;
    annotation.image = [UIImage imageNamed:@"pikaqiu.jpg"];
    
    [_mapView addAnnotation:annotation];
}

// 地图委托
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 这个定位是准确的，苹果已经对中国做了修正，效果最好
//    CLLocationCoordinate2D coord = [userLocation coordinate];
//    NSLog(@"经度:%f,纬度:%f",coord.latitude,coord.longitude);
//    [self addMapAnnotation:coord withTitle:@"我的位置" withSubtitle:@"好偏僻啊"];
}

// 显示大头针委托
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[CustomAnnoation class]])
    {
        static NSString *key = @"AnnotationKey";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key];
        // 如果缓存池中不存在则新建
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key];
            annotationView.canShowCallout = true; // 允许交互
        }
        
        // 设置大头针弹出视图
        annotationView.calloutOffset = CGPointMake(0, 1); // 定义详情视图偏移量
        annotationView.annotation = annotation;
        annotationView.image = [UIImage imageNamed:@"location_pin.png"];
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:((CustomAnnoation *)annotation).image];//定义详情左侧视图,可以根据传入坐标修改
        
        // 设置右侧视图，并添加事件
        annotationView.rightCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share.png"]];
        annotationView.rightCalloutAccessoryView.userInteractionEnabled = YES;
        [annotationView.rightCalloutAccessoryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnnotationView:)]];

        return annotationView;
    }
    else
    {
        return nil;
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // 点击了大头针就会调用
    NSLog(@"%@, %@", view.annotation.title, view.annotation.subtitle);
}

- (void)tapAnnotationView:(id)sender
{
    // 可以根据传参做一些事情，比如调起自带地图进行导航
    NSLog(@"点击了右侧按钮");
}

#pragma mark - 地理编解码
// 根据地名确定坐标
- (void)getCoordinateByAddress:(NSString *)address
{
    [_geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        //取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
        CLPlacemark *placemark=[placemarks firstObject];
        CLLocation *location = placemark.location;
        CLRegion *region = placemark.region;
        NSDictionary *addressDic= placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
        //        NSString *name=placemark.name;//地名
        //        NSString *thoroughfare=placemark.thoroughfare;//街道
        //        NSString *subThoroughfare=placemark.subThoroughfare; //街道相关信息，例如门牌等
        //        NSString *locality=placemark.locality; // 城市
        //        NSString *subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
        //        NSString *administrativeArea=placemark.administrativeArea; // 州
        //        NSString *subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
        //        NSString *postalCode=placemark.postalCode; //邮编
        //        NSString *ISOcountryCode=placemark.ISOcountryCode; //国家编码
        //        NSString *country=placemark.country; //国家
        //        NSString *inlandWater=placemark.inlandWater; //水源、湖泊
        //        NSString *ocean=placemark.ocean; // 海洋
        //        NSArray *areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标
        NSLog(@"位置:%@,区域:%@,详细信息:%@", location, region, addressDic);
    }];
}

// 根据坐标确定地名
- (void)getAddressByLocation:(CLLocation *)location
{
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
//        NSLog(@"详细信息:%@", placemark.addressDictionary);
        NSLog(@"%@", placemark.locality);
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
