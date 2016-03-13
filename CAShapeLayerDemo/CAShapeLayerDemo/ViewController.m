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
    CAShapeLayer  *shapeLayer;
    CADisplayLink *displayLink;
    
    UIView        *springView;
    
    BOOL          isStartting;
}

//@property (nonatomic, assign) CGFloat controlX;
//@property (nonatomic, assign) CGFloat controlY;

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
    
    //Spring animation
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake((self.view.frame.size.width-80)/2, 20, 80, 40);
    [btn2 setTitle:@"Spring" forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor greenColor] size:btn2.frame.size] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(startSpringAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    springView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x, 150, 5, 5)];
    springView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:springView];
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.view.center.x, 100)];
    [linePath addQuadCurveToPoint:CGPointMake(self.view.center.x, 300)
                     controlPoint:CGPointMake(self.view.center.x, 150)];

    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = linePath.CGPath;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;//线条颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shapeLayer.lineWidth = 1.0;
    [self.view.layer addSublayer:shapeLayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePa:)];
    [self.view addGestureRecognizer:pan];
    
    // CADisplayLink默认每秒运行60次calculatePath是算出在运行期间_curveView的坐标，从而确定_shapeLayer的形状
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
    
    isStartting = NO;
}

- (void)reflashCAShapeLayerPath:(CGPoint)control
{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.view.center.x, 100)];
    [linePath addQuadCurveToPoint:CGPointMake(self.view.center.x, 300)
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
                [self reflashCAShapeLayerPath:point];
                
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
                                     
                                     CGPoint point = CGPointMake(self.view.center.x, 150);
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

- (void)calculatePath
{
    // 由于手势结束时,r5执行了一个UIView的弹簧动画,把这个过程的坐标记录下来,并相应的画出_shapeLayer形状
    CALayer *layer = springView.layer.presentationLayer;
    [self reflashCAShapeLayerPath:CGPointMake(layer.position.x, layer.position.y)];
}

- (void)startSpringAnimation
{
    /*
     kCAMediaTimingFunctionLinear 线性动画
     kCAMediaTimingFunctionEaseIn 先慢后快（慢进快出）
     kCAMediaTimingFunctionEaseOut 先块后慢（快进慢出）
     kCAMediaTimingFunctionEaseInEaseOut 先慢后快再慢
     kCAMediaTimingFunctionDefault 默认，也属于中间比较快

     kCATransitionFade 渐变效果
     kCATransitionMoveIn 进入覆盖效果
     kCATransitionPush 推出效果
     kCATransitionReveal 揭露离开效果

     kCATransitionFromRight 从右侧进入
     kCATransitionFromLeft 从左侧进入
     kCATransitionFromTop 从顶部进入
     kCATransitionFromBottom 从底部进入

     */
    
    /*
    [UIView animateWithDuration:0.5 //持续时间
                          delay:1   //延迟时间
         usingSpringWithDamping:0.1 //阻尼系数，
          initialSpringVelocity:5.0 //初始的速度
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
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
