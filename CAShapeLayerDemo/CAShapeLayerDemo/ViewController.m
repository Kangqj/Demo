//
//  ViewController.m
//  CAShapeLayerDemo
//
//  Created by 康起军 on 16/3/6.
//  Copyright © 2016年 康起军. All rights reserved.
//

/*
UIBezierPath：
 http://justsee.iteye.com/blog/1972853
 http://blog.chinaunix.net/uid-20622737-id-3161025.html
弹簧动画： http://www.renfei.org/blog/ios-8-spring-animation.html
Demo： http://www.jianshu.com/p/21db20189c40
 
 layer.presentationLayer：当前动画层的对象
 
 获取当前动画层对象的坐标
 CALayer *layer = _curveView.layer.presentationLayer;
 layer.position.x;
 layer.position.y;
 */

#import "ViewController.h"
#import "UIImage+Generate.h"

@interface ViewController ()
{
    CAShapeLayer *shareLayerOne;
}

@end

@implementation ViewController

/*
 
            PI*3/2
            |
            |
            |
 PI ________|_______ 0
            |
            |
            |
            PI/2
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 20, 80, 40);
    [btn setTitle:@"animation" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor greenColor] size:btn.frame.size] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startCircleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    shareLayerOne = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(160, 200) radius:50 startAngle:M_PI * 3 / 2 endAngle:M_PI * 7 / 2 clockwise:YES];
    path.lineWidth = 5.0;
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    shareLayerOne.path = path.CGPath;
    shareLayerOne.strokeColor = [UIColor redColor].CGColor;//线条颜色
    shareLayerOne.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shareLayerOne.strokeStart = 0;
    shareLayerOne.strokeEnd = 0.25;
    [self.view.layer addSublayer:shareLayerOne];

}

- (void)startCircleAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setFromValue:@0.25];
    [animation setToValue:@1];
    [animation setDuration:5];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;//当动画结束后,layer会一直保持着动画最后的状态
    [shareLayerOne addAnimation:animation forKey:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
