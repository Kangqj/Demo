//
//  RadarView.h
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/7.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadarView : UIView
{
    NSMutableArray *layerArr;
}

- (void)start;
- (void)stop;

@end
