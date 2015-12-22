//
//  ViewController.m
//  CamouflageLocationDemo
//
//  Created by coverme on 15/12/22.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"
#import "KAnnotation.h"

@interface ViewController ()
{
    NSMutableArray *annoViewArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50)];
    m_MapView.delegate = self;
    m_MapView.showsUserLocation = YES;
    [m_MapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:m_MapView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 140)];
    contentView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    [m_MapView addSubview:contentView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [contentView addGestureRecognizer:pan];
    
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(0, 20, 80, 30);
    [locationBtn setTitle:@"Location" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanBtn.frame = CGRectMake(80, 20, 80, 30);
    [cleanBtn setTitle:@"Clean" forState:UIControlStateNormal];
    [cleanBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [cleanBtn addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cleanBtn];
    
    annoViewArr = [[NSMutableArray alloc] init];
}

- (void)location
{
    m_MapView.showsUserLocation = YES;
}

- (void)clean
{
    for (MKAnnotationView *annoView in annoViewArr)
    {
        [annoView removeFromSuperview];
    }
}

#pragma mark MKMapViewDelegate

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
//    if ([overlay isKindOfClass:[MKPolygon class]])
//    {
//        MKOverlayView *pview = [[MKOverlayView alloc] initWithOverlay:overlay];
//        pview.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4f];
//        
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//        [pview addGestureRecognizer:pan];
//        
//        return pview;
//    }
    
//    if ([overlay isKindOfClass:[MKCircle class]])
//    {
//        MKCircleView* circleView = [[MKCircleView alloc] initWithOverlay:overlay];
//        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
//        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
//        circleView.lineWidth = 3.0;
//        return circleView;
//    }
    
    MKCircleView* circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
    circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
    circleView.lineWidth = 3.0;
    return circleView;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:m_MapView];
    pan.view.center = point;
    [pan setTranslation:CGPointZero inView:m_MapView];
    

    if (pan.state == UIGestureRecognizerStateEnded)
    {
        CLLocationCoordinate2D cll = [m_MapView convertPoint:point toCoordinateFromView:m_MapView];
        KAnnotation *annotation = [[KAnnotation alloc] init];
        annotation.title = @"经过位置";
        annotation.coordinate = cll;
        [m_MapView addAnnotation:annotation];
    }
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    m_MapView.showsUserLocation = NO;
    
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:m_MapView.userLocation.location.coordinate radius:5000];
    [m_MapView addOverlay:circle];
    
    return;
    
    float gap = 0.001;
    CLLocationCoordinate2D center = m_MapView.userLocation.location.coordinate;
    CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
    CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
    CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
    CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
    
    CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
    [m_MapView addOverlay:polygon];
    
    KAnnotation *annotation = [[KAnnotation alloc] init];
    annotation.title = @"当前位置";
    annotation.coordinate = m_MapView.userLocation.location.coordinate;
    [m_MapView addAnnotation:annotation];
    
    NSLog(@"%@",m_MapView.userLocation.location.description);
}

#pragma mark - 地图控件代理方法
#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
//    if ([annotation isKindOfClass:[KAnnotation class]]) {
//        MKPinAnnotationView *pinview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mylocation"];
//        pinview.animatesDrop = YES;
//        pinview.pinTintColor = [UIColor greenColor];
//        pinview.selected = YES;
//        return pinview;
//    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    [annoViewArr addObjectsFromArray:views];
}

#pragma mark CLLocationManagerDelegate
-(void)startLocating
{
    if (![CLLocationManager locationServicesEnabled] ||
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        
        
        
    } else
    {
        if (locManager == nil) {
            locManager = [[CLLocationManager alloc] init];
            locManager.delegate = self;
            locManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locManager requestAlwaysAuthorization];
        }
        [locManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *alocation = [locations lastObject];
    if (alocation && location == nil) {
        location = alocation;
    }
    [locManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
