//
//  AnmationEngin.m
//  Fighting
//
//  Created by kangqijun on 14/11/5.
//  Copyright (c) 2014年 kangqijun. All rights reserved.
//

#import "AnimationEngin.h"

@implementation AnimationEngin
@synthesize contentView;
@synthesize startBlock,endBlock;
@synthesize popFinishBlock;

+ (void)flyAnimationQuadCurveToPoint:(CGPoint)toPoint withTime:(float)duration withTime:(UIView *)view
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	//Set some variables on the animation
	pathAnimation.calculationMode = kCAAnimationPaced;
	//We want the animation to persist - not so important in this case - but kept for clarity
	//If we animated something from left to right - and we wanted it to stay in the new position,
	//then we would need these parameters
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	pathAnimation.duration = duration;
	//Lets loop continuously for the demonstration
//	pathAnimation.repeatCount = 1;
	
    //抛物线轨迹
    CGFloat cpx = [UIScreen mainScreen].bounds.size.height/2;
    CGFloat cpy = 0;
    
    if (view.frame.origin.y > [UIScreen mainScreen].bounds.size.width/2)
    {
        cpy = [UIScreen mainScreen].bounds.size.width - 10;
    }
    else
    {
        cpy = 10;
    }
    
    CGFloat cpx1 = [UIScreen mainScreen].bounds.size.height/2;
    CGFloat cpy1 = 0;
    
    if (view.frame.origin.y > [UIScreen mainScreen].bounds.size.width/2)
    {
        cpy1 = 10;
    }
    else
    {
        cpy1 = [UIScreen mainScreen].bounds.size.width - 10;
    }
    
	CGMutablePathRef curvedPath = CGPathCreateMutable();
	CGPathMoveToPoint(curvedPath, NULL, view.frame.origin.x, view.frame.origin.y);
	CGPathAddQuadCurveToPoint(curvedPath, NULL, cpx, cpy, toPoint.x/2 + 70 , toPoint.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, cpx1, cpy1, toPoint.x, toPoint.y);
    [pathAnimation setPath:curvedPath];
    CFRelease(curvedPath);
    
    [view.layer addAnimation:pathAnimation forKey:@"moveTheSquare"];
}


+ (void)flyAddSmallerAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withTime:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk isBigger:(BOOL)bigger
{
    AnimationEngin *engin = [[AnimationEngin alloc] init];
    engin.startBlock = startBlk;
    engin.endBlock = endBlk;
//    engin.contentView = view;
    
	CGPoint pointerSize = view.center;
	CALayer *welcomeLayer = view.layer;
	
    // 位移的动画效果
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	bounceAnimation.calculationMode = kCAAnimationPaced;
    
    //设置移动结束位置
	CGMutablePathRef thePath = CGPathCreateMutable();
	CGFloat midX,midY;
    
	midX = toPoint.x;
	midY = toPoint.y;
    
    NSInteger yoff = fabsf(midY);
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger height = [UIScreen mainScreen].bounds.size.height;
    
    NSInteger cx = arc4random()%width;
    NSInteger cy = arc4random()%yoff;
    
    // 设置移动路径
	CGPathMoveToPoint(thePath, NULL, pointerSize.x, pointerSize.y);
	CGPathAddQuadCurveToPoint(thePath,NULL,cx,cy,midX,midY);
	
	bounceAnimation.path = thePath;
	CGPathRelease(thePath);
	
    // 放大/缩小动画效果
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
    
    if (bigger)
    {
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1,0.1,0.1)];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
    }
    else
    {
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
        transformAnimation.byValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(6,6,6)];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1,0.1,0.1)];
    }
    
    // 动画数组
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    // 将动画放入数组中
	theGroup.delegate = engin;
	theGroup.duration = duration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
    
    //执行动画
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewFromCenter"];

}

- (void)animationDidStart:(CAAnimation *)anim
{
//    CGRect rect = self.contentView.frame;
//    rect.origin.x = 0;
//    rect.origin.y = 0;
//    self.contentView.frame = rect;
    if (self.startBlock)
    {
        self.startBlock();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    if (flag)
//    {
//        [self.contentView removeFromSuperview];
//    }
    if (self.endBlock)
    {
        self.endBlock();
    }
    
    if (self.popFinishBlock)
    {
        self.popFinishBlock(self.contentView);
    }
}

+ (void)xinFlyAddSmallerAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withView:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk
{
    AnimationEngin *engin = [[AnimationEngin alloc] init];
    engin.startBlock = startBlk;
    engin.endBlock = endBlk;
    
	CGPoint pointerSize = view.center;
	CALayer *welcomeLayer = view.layer;
	
    // 位移的动画效果
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;//要做无限循环的动画，动画的removedOnCompletion属性必须设置为NO，否则运行一次动画就会销毁。
	bounceAnimation.calculationMode = kCAAnimationPaced;
    
    //设置移动结束位置
	CGMutablePathRef thePath = CGPathCreateMutable();
	CGFloat midX,midY;
	midX = toPoint.x;
	midY = toPoint.y;
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger height = [UIScreen mainScreen].bounds.size.height;
    
    NSInteger yoff = fabsf(midY);
    
    NSInteger cx = arc4random()%width;
    NSInteger cy = arc4random()%yoff;
    
    // 设置移动路径
	CGPathMoveToPoint(thePath, NULL, pointerSize.x, pointerSize.y);
	CGPathAddQuadCurveToPoint(thePath,NULL,cx,cy,midX,midY);
	
	bounceAnimation.path = thePath;
	CGPathRelease(thePath);
	
    // 放大/缩小动画效果
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
    transformAnimation.byValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6,0.6,0.6)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.14,0.14,0.14)];
    
    // 动画数组
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    // 将动画放入数组中
	theGroup.delegate = engin;
	theGroup.duration = duration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
    
    //执行动画
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewFromCenter"];
    
}

//找到的心飞行动画
+ (void)selectXinFlyAnimationToPoint:(CGPoint)toPoint withTime:(float)duration withView:(UIView *)view startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk
{
    AnimationEngin *engin = [[AnimationEngin alloc] init];
    engin.startBlock = startBlk;
    engin.endBlock = endBlk;
    
	CGPoint pointerSize = view.center;
	CALayer *welcomeLayer = view.layer;
	
    // 位移的动画效果
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;//要做无限循环的动画，动画的removedOnCompletion属性必须设置为NO，否则运行一次动画就会销毁。
	bounceAnimation.calculationMode = kCAAnimationPaced;
    
    //设置移动结束位置
	CGMutablePathRef thePath = CGPathCreateMutable();
	CGFloat midX,midY;
	midX = toPoint.x;
	midY = toPoint.y;
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger height = [UIScreen mainScreen].bounds.size.height;
    
    NSInteger yoff = fabsf(midY);
    
    NSInteger cx = arc4random()%width;
    NSInteger cy = arc4random()%yoff;
    
    // 设置移动路径
	CGPathMoveToPoint(thePath, NULL, pointerSize.x, pointerSize.y);
	CGPathAddQuadCurveToPoint(thePath,NULL,cx,cy,midX,midY);
	
	bounceAnimation.path = thePath;
	CGPathRelease(thePath);
	
    // 放大/缩小动画效果
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1,1,1)];
    transformAnimation.byValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(15,15,15)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(4/3,4/3,4/3)];
    
    // 动画数组
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    // 将动画放入数组中
	theGroup.delegate = engin;
	theGroup.duration = duration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
    
    //执行动画
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewFromCenter"];
    
}

//跑马灯动画
+ (void)showMarqueeAnimation:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin.x = kMainScreenWidth;
    view.frame = frame;
    
    [UIView animateWithDuration:15.0
                          delay:0
                        options:UIViewAnimationOptionRepeat //动画重复的主开关
     |UIViewAnimationOptionCurveLinear //动画的时间曲线，滚动字幕线性比较合理
                     animations:^{
                         
                         CGRect frame = view.frame;
                         frame.origin.x = -frame.size.width;
                         view.frame = frame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

//抖动动画
+ (void)shakeAnimation:(UIView *)view repeatCount:(NSInteger)num
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:- 0.2];
    shake.toValue   = [NSNumber numberWithFloat:+ 0.2];
    shake.duration = 0.1;
    shake.autoreverses = YES;//是否回复
    shake.repeatCount = num;
    
    [view.layer addAnimation:shake forKey:@"bagShakeAnimation"];
}

//上下浮动动画
+ (void)driftAnimation:(UIView *)view withTime:(float)duration Yoffset:(float)offset;
{
    float Yorigin = view.frame.origin.y;
    
    [UIView animateWithDuration:10.0
                          delay:0
                        options:UIViewAnimationOptionRepeat //动画重复的主开关
     |UIViewAnimationOptionCurveLinear //动画的时间曲线，滚动字幕线性比较合理
                     animations:^{
                         
                         CGRect frame = view.frame;
                         frame.origin.y = offset;
                         view.frame = frame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [self driftAnimation:view withTime:duration Yoffset:Yorigin];
                         
                     }
     ];
}

//翻页动画
+ (void)turnOffAnimation:(UIView *)view withTime:(float)duration startAnimation:(void (^)(void))startBlk endAnimation:(void (^)(void))endBlk
{
    AnimationEngin *engin = [[AnimationEngin alloc] init];
    engin.startBlock = startBlk;
    engin.endBlock = endBlk;
    
    CALayer *welcomeLayer = view.layer;
    
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    //2.设置动画属性初始值、结束值
    //    basicAnimation.fromValue=[NSNumber numberWithInt:M_PI_2];
    basicAnimation.toValue=[NSNumber numberWithFloat:M_PI];
    
    //设置其他动画属性
    //    basicAnimation.duration=6.0;
    basicAnimation.autoreverses=true;//旋转后在旋转到原来的位置
    basicAnimation.repeatCount=0;//设置无限循环
    basicAnimation.removedOnCompletion=NO;
    //    basicAnimation.delegate=self;
    
    
    //4.添加动画到图层，注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
    //    [_layer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Rotation"];
    
    // 动画数组
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    // 将动画放入数组中
    theGroup.delegate = engin;
    theGroup.duration = duration;
    theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    theGroup.animations = [NSArray arrayWithObjects:basicAnimation, nil];
    
    //执行动画
    [welcomeLayer addAnimation:theGroup forKey:@"KCBasicAnimation_Rotation"];
    
}

+ (void)registerEffectForView:(UIView *)aView depth:(CGFloat)depth;
{
    UIInterpolatingMotionEffect *effectX;
    UIInterpolatingMotionEffect *effectY;
    effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                              type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    
    effectX.maximumRelativeValue = @(depth);
    effectX.minimumRelativeValue = @(-depth);
    effectY.maximumRelativeValue = @(depth);
    effectY.minimumRelativeValue = @(-depth);
    
    [aView addMotionEffect:effectX];
    [aView addMotionEffect:effectY];
}

+ (void)popoverDismissAnimation:(BOOL)ispopover view:(UIView *)view dismissFinish:(void (^)(UIView *view))endBlk
{
    AnimationEngin *engin = [[AnimationEngin alloc] init];
    engin.popFinishBlock = endBlk;
    engin.contentView = view;
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    
    NSMutableArray *values = [NSMutableArray array];
    
    if (ispopover)
    {
        view.hidden = NO;
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    else
    {
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.delegate = engin;
    }
    
    animation.values = values;
    [view.layer addAnimation:animation forKey:nil];
}


@end
