//
//  KProgressHUD.h
//  CrazyRabbiter
//
//  Created by 康起军 on 14-10-20.
//  Copyright (c) 2014年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define AnimatehDuration 0.5
#define HUDStayTime      1.0
#define HUDTextFont      15
#define HUDyOffset       375

@interface KProgressHUD : NSObject
{
    UIView *HUDView;
}

@property (retain, nonatomic) UIView *HUDView;
@property (assign, nonatomic) float dTime;
@property (assign, nonatomic) float yoffset;

+ (KProgressHUD *)showHUDWithText:(NSString *)text height:(float)height;
+ (KProgressHUD *)showHUDWithText:(NSString *)text delay:(float)time height:(float)height;

- (void)dissmissHUD;

@end
