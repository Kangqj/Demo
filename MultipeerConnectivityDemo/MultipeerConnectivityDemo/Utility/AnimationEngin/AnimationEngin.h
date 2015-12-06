//
//  AnmationEngin.h
//  Fighting
//
//  Created by kangqijun on 14/11/5.
//  Copyright (c) 2014年 kangqijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void (^ Popover)(UIView *view);

@interface AnimationEngin : NSObject
{
    UIView *contentView;
}

@property (strong, nonatomic) UIView *contentView;
@property (copy, nonatomic) void (^startBlock)();
@property (copy, nonatomic) void (^endBlock)();
@property (copy, nonatomic) void (^popFinishBlock)(UIView *view);;


//抛物线帧动画飞行动画
+ (void)flyAnimationQuadCurveToPoint:(CGPoint)toPoint withTime:(float)duration withTime:(UIView *)view;

//直线缩小逐渐消失飞行动画
+ (void)flyAddSmallerAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withTime:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk isBigger:(BOOL)bigger;

//跑马灯动画
+ (void)showMarqueeAnimation:(UIView *)view;

//抖动动画
+ (void)shakeAnimation:(UIView *)view repeatCount:(NSInteger)num;

//上下浮动动画
+ (void)driftAnimation:(UIView *)view withTime:(float)duration Yoffset:(float)offset;

//签到心飞行动画
+ (void)xinFlyAddSmallerAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withView:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk;

//找到的心飞行动画
+ (void)selectXinFlyAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withView:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk;

//翻页动画
+ (void)turnOffAnimation:(UIView *)view withTime:(float)duration startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk;

//倾斜设备，图片也跟着动
+ (void)registerEffectForView:(UIView *)aView depth:(CGFloat)depth;

//弹出/消失动画
+ (void)popoverDismissAnimation:(BOOL)ispopover view:(UIView *)view dismissFinish:(void (^)(UIView *view))endBlk;


@end
