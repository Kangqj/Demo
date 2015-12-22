//
//  ViewController.h
//  CamouflageLocationDemo
//
//  Created by coverme on 15/12/22.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView		*m_MapView;
    CLLocationManager	*locManager;
    CLLocation			*location;//定位得到的信息
    
    UIView *contentView;
}

@end

