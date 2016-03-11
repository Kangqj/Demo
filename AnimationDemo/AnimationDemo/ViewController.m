//
//  ViewController.m
//  AnimationDemo
//
//  Created by 康起军 on 16/3/11.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Generate.h"

@interface ViewController ()
{
    CAShapeLayer *shapeLayer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Circle animation
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 20, 80, 40);
    [btn1 setTitle:@"Circle" forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor brownColor] size:btn1.frame.size] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(startCircleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    //圆圈路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(60, 200) radius:50 startAngle:M_PI * 3 / 2 endAngle:M_PI * 7 / 2 clockwise:YES];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //对勾路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(30, 200)];
    [linePath addLineToPoint:CGPointMake(60, 220)];
    [linePath addLineToPoint:CGPointMake(90, 190)];
    
    //拼接两个贝塞尔曲线
    [path appendPath:linePath];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor greenColor].CGColor;//线条颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shapeLayer.lineWidth = 5.0;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 0.0;
    [self.view.layer addSublayer:shapeLayer];
}

- (void)startCircleAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    if (shapeLayer.strokeEnd == 1.0)
    {
        [animation setFromValue:@1.0];
        [animation setToValue:@0.0];
    }
    else
    {
        [animation setFromValue:@0.0];
        [animation setToValue:@1.0];
    }
    
    [animation setDuration:3];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;//当动画结束后,layer会一直保持着动画最后的状态
    animation.delegate = self;
    [shapeLayer addAnimation:animation forKey:@"Circle"];
}


#pragma -mark CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        if (shapeLayer.strokeEnd == 0.0)
        {
            shapeLayer.strokeEnd = 1.0;
        }
        else
        {
            shapeLayer.strokeEnd = 0.0;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
