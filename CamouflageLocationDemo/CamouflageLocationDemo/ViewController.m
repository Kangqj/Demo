//
//  ViewController.m
//  CamouflageLocationDemo
//
//  Created by coverme on 15/12/22.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"
#import "KAnnotation.h"
#include <math.h>

@interface ViewController ()
{
    CLLocationCoordinate2D userCoor;
    CLGeocoder *geocoder;
    
    UITextField *textField;
    
    double oldSpanArea;
    
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation ViewController
@synthesize geocoder;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    m_MapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50)];
    m_MapView.delegate = self;
    m_MapView.showsUserLocation = YES;
    [m_MapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:m_MapView];
    
    fenceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    fenceView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:fenceView];
    fenceView.layer.borderColor = [UIColor redColor].CGColor;
    fenceView.layer.borderWidth = 2.0;
    fenceView.center = CGPointMake(m_MapView.frame.size.width/2, m_MapView.frame.size.height/2);
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 50, 60)];
    contentView.backgroundColor = [UIColor clearColor];//[[UIColor greenColor] colorWithAlphaComponent:0.4];
    [m_MapView addSubview:contentView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewHandlePan:)];
    [contentView addGestureRecognizer:pan];
    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
//    [m_MapView addGestureRecognizer:tapRecognizer];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinchGesture setDelegate:self];
    [m_MapView addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *mappan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewHandlePan:)];
    [mappan setDelegate:self];
    [m_MapView addGestureRecognizer:mappan];
    
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
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(160, 20, self.view.frame.size.width-240, 30)];
    [self.view addSubview:textField];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(self.view.frame.size.width-80, 20, 80, 30);
    [searchBtn setTitle:@"search" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    //定位授权
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
}

- (void)mapViewHandlePan:(UIPanGestureRecognizer *)pan
{
    NSLog(@"--------------地图拖动事件");
}

- (void)contentViewHandlePan:(UIPanGestureRecognizer *)pan
{
    NSLog(@"--------------MKOverlayView拖动事件");
    
    [self clean];
    CGPoint point = [pan locationInView:m_MapView];
    contentView.center = point;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    float gap = 0.001;
    
    CLLocationCoordinate2D center = [m_MapView convertPoint:point toCoordinateFromView:m_MapView];
    userCoor = center;
    CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
    CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
    CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
    CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
    
    CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
    [m_MapView addOverlay:polygon];
}

- (void)handleTapRecognizer:(UITapGestureRecognizer *)tap
{
    NSLog(@"--------------地图点击事件");
    CGPoint point = [tap locationInView:m_MapView];
    
    [self clean];
    
    float gap = 0.001;
    
    CLLocationCoordinate2D center = [m_MapView convertPoint:point toCoordinateFromView:m_MapView];
    userCoor = center;
    CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
    CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
    CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
    CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
    
    CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
    [m_MapView addOverlay:polygon];
    
    
    CLLocationCoordinate2D annpoint = CLLocationCoordinate2DMake(center.latitude - gap/2, center.longitude - gap*2);
    
    KAnnotation *annotation = [[KAnnotation alloc] init];
    annotation.coordinate = annpoint;
    [m_MapView addAnnotation:annotation];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture
{
    NSLog(@"--------------地图缩放事件");
    CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
    contentView.center = point;
    if (oldSpanArea)
    {
        double newSpan = m_MapView.region.span.latitudeDelta * m_MapView.region.span.longitudeDelta;
        
        float ratio  = oldSpanArea/newSpan;
        float width = sqrtf(ratio * (fenceView.frame.size.width * fenceView.frame.size.height));
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = fenceView.frame;
            rect.size.width = width;
            rect.size.height = width;
            fenceView.frame = rect;
            
            fenceView.center = CGPointMake(m_MapView.frame.size.width/2, m_MapView.frame.size.height/2);
            
        }];
    }
    
    oldSpanArea = m_MapView.region.span.latitudeDelta * m_MapView.region.span.longitudeDelta;
}

- (void)location
{
    [m_MapView setRegion:MKCoordinateRegionMake(m_MapView.userLocation.coordinate, m_MapView.region.span) animated:YES];
}

- (void)clean
{
//    for (KAnnotation *annotation in m_MapView.annotations)//删除大头针
//    {
//        [m_MapView removeAnnotation:annotation];
//    }
    
//    for (id overlays in m_MapView.overlays)//删除所有区域和线路
//    {
//        if ([overlays isKindOfClass:[MKPolyline class]] || [overlays isKindOfClass:[MKPolygon class]])
//        {
//            [m_MapView removeOverlay:overlays];
//        }
//    }
    
    [m_MapView removeAnnotations:m_MapView.annotations];//删除所有大头针
    [m_MapView removeOverlays:m_MapView.overlays];//删除所有区域和线路
}

- (void)search
{
    [textField resignFirstResponder];
    
    [self switchWithPlace:textField.text];
}

- (void)switchWithPlace:(NSString *)place
{
    [self.geocoder geocodeAddressString:place completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0)
        {
            CLPlacemark *mark = [placemarks objectAtIndex:0];
            NSLog(@"%@",mark.name);
            userCoor = CLLocationCoordinate2DMake(mark.location.coordinate.latitude, mark.location.coordinate.longitude);
            [m_MapView setRegion:MKCoordinateRegionMake(userCoor, m_MapView.region.span) animated:YES];
            
            [self clean];
            
            float gap = 0.001;
            
            CLLocationCoordinate2D center = userCoor;
            CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
            CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
            CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
            CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
            
            CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
            MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
            [m_MapView addOverlay:polygon];
            
            KAnnotation *annotation = [[KAnnotation alloc] init];
//            annotation.title = @"当前位置";
            annotation.coordinate = center;
            [m_MapView addAnnotation:annotation];
        }
        else if ([placemarks count] == 0 &&
                 error == nil){
            NSLog(@"Found no placemarks.");
        }
        else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
    }];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark MKMapViewDelegate

//当拖拽，放大，缩小，双击手势开始时调用
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
    contentView.center = point;
}

//当拖拽，放大，缩小，双击手势结束时调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
    contentView.center = point;
    
    if (m_MapView.showsUserLocation == NO)
    {
        if (oldSpanArea)
        {
            double newSpan = m_MapView.region.span.latitudeDelta * m_MapView.region.span.longitudeDelta;
            
            float ratio  = oldSpanArea/newSpan;
            float width = sqrtf(ratio * (fenceView.frame.size.width * fenceView.frame.size.height));
            
            [UIView animateWithDuration:0.3 animations:^{
                
                CGRect rect = fenceView.frame;
                rect.size.width = width;
                rect.size.height = width;
                fenceView.frame = rect;
                
                fenceView.center = CGPointMake(m_MapView.frame.size.width/2, m_MapView.frame.size.height/2);
                
            }];
        }
        
        oldSpanArea = m_MapView.region.span.latitudeDelta * m_MapView.region.span.longitudeDelta;
    }
}


-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKOverlayView *pview = [[MKOverlayView alloc] initWithOverlay:overlay];
        pview.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4f];
        
        return pview;
    }
    else if ([overlay isKindOfClass:[MKCircleView class]])
    {
        MKCircleView* circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        circleView.lineWidth = 3.0;
        return circleView;
    }
    else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *lineview = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineview.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        lineview.lineWidth = 2.0;
        return lineview;
    }
    
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation:%f, %f",m_MapView.region.span.latitudeDelta,m_MapView.region.span.longitudeDelta);
    
    userCoor = userLocation.coordinate;
    
    m_MapView.showsUserLocation = NO;
    
    [m_MapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, m_MapView.region.span) animated:YES];
    
    //加圆形区域
//    MKCircle* circle = [MKCircle circleWithCenterCoordinate:m_MapView.userLocation.location.coordinate radius:5000];
//    [m_MapView addOverlay:circle];
//    
//    return;
    
    //加矩形区域
    float gap = 0.001;
    CLLocationCoordinate2D center = userLocation.coordinate;
    CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
    CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
    CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
    CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
    
    CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
    [m_MapView addOverlay:polygon];
    
    
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(m_MapView.userLocation.location.coordinate.latitude - gap/2, m_MapView.userLocation.location.coordinate.longitude - gap*2);
    KAnnotation *annotation = [[KAnnotation alloc] init];
    annotation.title = @"当前位置";
    annotation.coordinate = point;
    [m_MapView addAnnotation:annotation];
    
    //画线条
//    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordinates count:4];
//    [m_MapView addOverlay:line];
}

#pragma mark - 地图控件代理方法
#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    
    pin.canShowCallout=YES;
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.selected = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    switch (newState) {
            
        case MKAnnotationViewDragStateStarting: {
            
            NSLog(@"拿起");
            
            break;
        }
            
        case MKAnnotationViewDragStateDragging: {
            
            NSLog(@"开始拖拽");
            
            break;
        }
            
        case MKAnnotationViewDragStateEnding: {
            
            NSLog(@"放下,并将大头针");
            
            NSLog(@"x is %f", view.center.x);
            NSLog(@"y is %f", view.center.y);
            
            CGPoint dropPoint = CGPointMake(view.center.x, view.center.y);
            CLLocationCoordinate2D newCoordinate = [mapView convertPoint:dropPoint toCoordinateFromView:view.superview];
            [view.annotation setCoordinate:newCoordinate];
            
            break;
        }
            
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
