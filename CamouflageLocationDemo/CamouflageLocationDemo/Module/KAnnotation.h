//
//  KAnnotation.h
//  CamouflageLocationDemo
//
//  Created by coverme on 15/12/22.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KAnnotation : NSObject <MKAnnotation>
{
//    CLLocationCoordinate2D coordinate;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

//- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
//- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
