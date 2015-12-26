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
    
    CLLocationCoordinate2D userCoor;
    CLGeocoder *geocoder;
    
    UITextField *textField;
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
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 50, 60)];
    contentView.backgroundColor = [UIColor clearColor];//[[UIColor greenColor] colorWithAlphaComponent:0.4];
    [m_MapView addSubview:contentView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [contentView addGestureRecognizer:pan];
    
//    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongRecognizer:)];
//    longRecognizer.allowableMovement = 1024;
//    longRecognizer.minimumPressDuration = 1;
//    [m_MapView addGestureRecognizer:longRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
    [m_MapView addGestureRecognizer:tapRecognizer];
    
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
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(160, 20, self.view.frame.size.width-240, 30)];
    [self.view addSubview:textField];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(self.view.frame.size.width-80, 20, 80, 30);
    [searchBtn setTitle:@"search" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
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
    
    KAnnotation *annotation = [[KAnnotation alloc] init];
    annotation.title = @"当前位置";
    annotation.coordinate = center;
    [m_MapView addAnnotation:annotation];
}

- (void)handlelongRecognizer:(UILongPressGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:m_MapView];
    
    if (pan.state == UIGestureRecognizerStateBegan)
    {
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
        
        KAnnotation *annotation = [[KAnnotation alloc] init];
        annotation.title = @"当前位置";
        annotation.coordinate = center;
        [m_MapView addAnnotation:annotation];
    }
    
}

- (void)handleTapRecognizer:(UITapGestureRecognizer *)tap
{
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
    
    KAnnotation *annotation = [[KAnnotation alloc] init];
    annotation.title = @"当前位置";
    annotation.coordinate = center;
    [m_MapView addAnnotation:annotation];
    
}

- (void)location
{
//    m_MapView.showsUserLocation = YES;
//    [self startLocating];
    [m_MapView setRegion:MKCoordinateRegionMake(m_MapView.userLocation.coordinate, m_MapView.region.span) animated:YES];
}

- (void)clean
{
//    for (MKAnnotationView *annoView in annoViewArr)
//    {
//        [annoView removeFromSuperview];
//    }
    
    for (KAnnotation *annotation in m_MapView.annotations)//删除大头针
    {
        [m_MapView removeAnnotation:annotation];
    }
    
    for (id overlays in m_MapView.overlays)//删除区域和线路
    {
        if ([overlays isKindOfClass:[MKPolyline class]] || [overlays isKindOfClass:[MKPolygon class]])
        {
            [m_MapView removeOverlay:overlays];
        }
    }
}

- (void)search
{
    [textField resignFirstResponder];
    
    [self switchWithPlace:textField.text];
}

- (void)switchWithPlace:(NSString *)place
{
    self.geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder geocodeAddressString:place completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0)
        {
            CLPlacemark *mark = [placemarks objectAtIndex:0];
            
            userCoor = CLLocationCoordinate2DMake(mark.location.coordinate.latitude, mark.location.coordinate.longitude);
            [m_MapView setRegion:MKCoordinateRegionMake(userCoor, m_MapView.region.span) animated:YES];
            
            [self clean];
            
//            CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
            
            float gap = 0.001;
            
//            CLLocationCoordinate2D center = [m_MapView convertPoint:point toCoordinateFromView:m_MapView];
            CLLocationCoordinate2D center = userCoor;
            CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
            CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
            CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
            CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);
            
            CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
            MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
            [m_MapView addOverlay:polygon];
            
            KAnnotation *annotation = [[KAnnotation alloc] init];
            annotation.title = @"当前位置";
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

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
    contentView.center = point;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CGPoint point = [m_MapView convertCoordinate:userCoor toPointToView:m_MapView];
    contentView.center = point;
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

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    userCoor = userLocation.coordinate;
    
    m_MapView.showsUserLocation = NO;
    
    [m_MapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, m_MapView.region.span) animated:YES];
    
//    MKCircle* circle = [MKCircle circleWithCenterCoordinate:m_MapView.userLocation.location.coordinate radius:5000];
//    [m_MapView addOverlay:circle];
//    
//    return;
    
    float gap = 0.001;
    CLLocationCoordinate2D center = userLocation.coordinate;
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
    
    
//    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordinates count:4];
//    [m_MapView addOverlay:line];
}

#pragma mark - 地图控件代理方法
#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[KAnnotation class]]) {
        MKPinAnnotationView *pinview = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mylocation"];
        pinview.animatesDrop = NO;
        pinview.pinTintColor = [UIColor redColor];
        pinview.selected = YES;
        return pinview;
    }
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
        
//        [m_MapView setRegion:MKCoordinateRegionMake(alocation.coordinate, m_MapView.region.span) animated:YES];
    }
    
    [m_MapView setRegion:MKCoordinateRegionMake(alocation.coordinate, m_MapView.region.span) animated:YES];
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
