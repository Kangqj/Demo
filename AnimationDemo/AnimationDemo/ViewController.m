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
    UIButton *animationBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Circle animation
    animationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    animationBtn.frame = CGRectMake((self.view.frame.size.width-80)/2, 80, 80, 40);
    [animationBtn setTitle:@"Start" forState:UIControlStateNormal];
    [animationBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor brownColor] size:animationBtn.frame.size] forState:UIControlStateNormal];
    [animationBtn addTarget:self action:@selector(startCircleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:animationBtn];
    
    //圆圈路径
    CGPoint center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);//圆心
    float radius = 50;//半径
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:M_PI * 3 / 2 endAngle:M_PI * 7 / 2 clockwise:YES];//顺时针绘制
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //对勾路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(center.x - radius + 20, center.y)];
    [linePath addLineToPoint:CGPointMake(center.x, center.y+20)];
    [linePath addLineToPoint:CGPointMake(center.x + radius - 15, center.y - 15)];
    
    //拼接两个路径
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
            
            [animationBtn setTitle:@"Back" forState:UIControlStateNormal];
            [animationBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor redColor] size:animationBtn.frame.size] forState:UIControlStateNormal];

        }
        else
        {
            shapeLayer.strokeEnd = 0.0;
            
            [animationBtn setTitle:@"Start" forState:UIControlStateNormal];
            [animationBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor brownColor] size:animationBtn.frame.size] forState:UIControlStateNormal];

        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
