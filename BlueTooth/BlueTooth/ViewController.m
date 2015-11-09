//
//  ViewController.m
//  BlueTooth
//
//  Created by Kangqj on 15/10/30.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"
#import "CentralViewController.h"
#import "PeripheralViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
{
    CLLocationManager* locationmanager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"选择模式";
    
    UIButton *broadcast = [UIButton buttonWithType:UIButtonTypeCustom];
    broadcast.frame = CGRectMake(20, 80, self.view.frame.size.width-40, 40);
    [broadcast setTitle:@"广播服务（Peripheral）" forState:UIControlStateNormal];
    broadcast.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    broadcast.backgroundColor = [UIColor grayColor];
    broadcast.layer.cornerRadius = 10;
    [self.view addSubview:broadcast];
    [broadcast addTarget:self action:@selector(broadcastService) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *recive = [UIButton buttonWithType:UIButtonTypeCustom];
    recive.frame = CGRectMake(20, 160, self.view.frame.size.width-40, 40);
    [recive setTitle:@"接收服务（Central）" forState:UIControlStateNormal];
    recive.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    recive.backgroundColor = [UIColor grayColor];
    recive.layer.cornerRadius = 10;
    [self.view addSubview:recive];
    [recive addTarget:self action:@selector(reciveService) forControlEvents:UIControlEventTouchUpInside];
    
    locationmanager = [[CLLocationManager alloc]init];
    
    //设置精度
    /*
     kCLLocationAccuracyBest
     kCLLocationAccuracyNearestTenMeters
     kCLLocationAccuracyHundredMeters
     kCLLocationAccuracyHundredMeters
     kCLLocationAccuracyKilometer
     kCLLocationAccuracyThreeKilometers
     */
    //设置定位的精度
    [locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
    //实现协议
    locationmanager.delegate = self;
    //开始定位
    [locationmanager startUpdatingLocation];
}

- (void)broadcastService
{
    PeripheralViewController *vc = [[PeripheralViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reciveService
{
    CentralViewController *vc = [[CentralViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark locationManager delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //打印出精度和纬度
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    NSLog(@"输出当前的精度和纬度");
    NSLog(@"精度：%f 纬度：%f",coordinate.latitude,coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        CLLocationCoordinate2D coordinate = location.coordinate;
        NSLog(@"精度：%f 纬度：%f",coordinate.latitude,coordinate.longitude);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
