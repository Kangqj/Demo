//
//  ViewController.m
//  CAShapeLayerDemo
//
//  Created by 康起军 on 16/3/6.
//  Copyright © 2016年 康起军. All rights reserved.
//

/*
UIBezierPath： http://justsee.iteye.com/blog/1972853
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
    UIView       *springView;
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
    
    //Circle animation
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 20, 80, 40);
    [btn1 setTitle:@"Circle" forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor greenColor] size:btn1.frame.size] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(startCircleAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    shareLayerOne = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(60, 200) radius:50 startAngle:M_PI * 3 / 2 endAngle:M_PI * 7 / 2 clockwise:YES];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    shareLayerOne.path = path.CGPath;
    shareLayerOne.strokeColor = [UIColor redColor].CGColor;//线条颜色
    shareLayerOne.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shareLayerOne.lineWidth = 5.0;
    shareLayerOne.strokeStart = 0;
    shareLayerOne.strokeEnd = 0.25;
    [self.view.layer addSublayer:shareLayerOne];
    
    //Spring animation
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 20, 80, 40);
    [btn2 setTitle:@"Spring" forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor greenColor] size:btn2.frame.size] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startSpringAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    springView = [[UIView alloc] initWithFrame:CGRectMake(120, 100, 80, 20)];
    springView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:springView];
}

- (void)startCircleAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    if (shareLayerOne.strokeEnd == 1.0)
    {
        [animation setFromValue:@1];
        [animation setToValue:@0.25];
    }
    else
    {
        [animation setFromValue:@0.25];
        [animation setToValue:@1];
    }
    
    [animation setDuration:5];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;//当动画结束后,layer会一直保持着动画最后的状态
    animation.delegate = self;
    [shareLayerOne addAnimation:animation forKey:@"Circle"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        if (shareLayerOne.strokeEnd == 0.25)
        {
            shareLayerOne.strokeEnd = 1.0;
        }
        else
        {
            shareLayerOne.strokeEnd = 0.25;
        }
    }
}

- (void)startSpringAnimation
{
    [UIView animateWithDuration:0.5
                          delay:1
         usingSpringWithDamping:0.2 //初始的速度，数值越大一开始移动越快, 初始速度取值较高而时间较短时，也会出现反弹情况
          initialSpringVelocity:5.0 //弹簧系数, 数值越小, 的振动效果越明显
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect rect = springView.frame;
                         if (rect.size.height == 150)
                         {
                             rect.size.height = 20;
                         }
                         else
                         {
                             rect.size.height = 150;
                         }
                         
                         springView.frame = rect;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         CALayer *layer = springView.layer.presentationLayer;
                         NSLog(@"%f---%f",layer.position.x, layer.position.y);

                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
