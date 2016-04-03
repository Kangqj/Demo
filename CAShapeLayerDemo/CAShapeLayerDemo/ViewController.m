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
*/

#import "ViewController.h"
#import "UIImage+Generate.h"

@interface ViewController ()
{
    CAShapeLayer  *shapeLayer;
    CADisplayLink *displayLink;
    
    UIView        *springView;
    
    BOOL          isStartting;
}

@end

@implementation ViewController

//@synthesize controlX, controlY;

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
    
    //控制点视图
    springView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x, 300, 5, 5)];
    springView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:springView];
    
    //贝塞尔曲线
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.view.center.x, 200)];
    [linePath addQuadCurveToPoint:CGPointMake(self.view.center.x, 400)
                     controlPoint:CGPointMake(self.view.center.x, 300)];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = linePath.CGPath;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;//线条颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shapeLayer.lineWidth = 1.0;
    [self.view.layer addSublayer:shapeLayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePa:)];
    [self.view addGestureRecognizer:pan];
    
    //扫描定时器
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
    
    isStartting = NO;
}

//刷新曲线路径
- (void)reflashShapeLayerPath:(CGPoint)control
{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.view.center.x, 200)];
    [linePath addQuadCurveToPoint:CGPointMake(self.view.center.x, 400)
                     controlPoint:CGPointMake(control.x, control.y)];
    shapeLayer.path = linePath.CGPath;
}

- (void)handlePa:(UIPanGestureRecognizer *)pan
{
    if (!isStartting)
    {
        switch (pan.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                
                break;
            }
                
            case UIGestureRecognizerStateChanged:
            {
                CGPoint point = [pan locationInView:self.view];
                
                [self reflashShapeLayerPath:point];
                
                springView.frame = CGRectMake(point.x, point.y, 5, 5);
                
                break;
            }
                
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {                
                displayLink.paused = NO;
                isStartting = YES;

                [UIView animateWithDuration:0.5 //持续时间
                                      delay:0   //延迟时间
                     usingSpringWithDamping:0.1 //阻尼系数，
                      initialSpringVelocity:0.0 //初始的速度
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     
                                     CGPoint point = CGPointMake(self.view.center.x, 300);
                                     springView.frame = CGRectMake(point.x, point.y, 5, 5);
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     if (finished)
                                     {
                                         displayLink.paused = YES;
                                         isStartting = NO;
                                     }
                                 }];
                break;
            }
                
            default:
                break;
        }
    }
}

//扫描方法
- (void)calculatePath
{
    CALayer *layer = springView.layer.presentationLayer;
    [self reflashShapeLayerPath:CGPointMake(layer.position.x, layer.position.y)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
