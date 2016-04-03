> 吐槽：前段时间忙的一米，公司的产品急着发版本，自己接的私活客户那边也在催着要，实在没时间维护简书这边的笔记。好在清明节假期来了，可以休息一下，搞搞好玩的东西。

![](http://upload-images.jianshu.io/upload_images/670087-0e4515adfeeb3ad3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

防琴弦波动的这个动画源于之前看到别人写的一个弹性动画，觉得很有意思，所以自己也琢磨着写一个看看。

### 1.使用到的相关类：
- `贝塞尔曲线-UIBezierPath`
- `CAShapeLayer`
- `CADisplayLink`
> CADisplayLink与NSTimer定时器类似，调用的时间和iOS设备的屏幕刷新频率相同－每秒60次，所以它可以确保系统渲染每一帧的时候selector方法都被调用，从而保证了动画的流畅性。
- `Spring Animation`
> iOS8以后开放使用，主要参数：
usingSpringWithDamping：阻尼系数，取值范围：[0.0，1.0]，数值越小，弹簧振动效果越明显；
initialSpringVelocity：初始速度，数值越大，初始速度越大；

```
[UIView animateWithDuration:(NSTimeInterval)    //持续时间
                          delay:(NSTimeInterval)//延迟执行时间
         usingSpringWithDamping:(CGFloat)       //阻尼系数
          initialSpringVelocity:(CGFloat)       //初始的速度
                        options:(UIViewAnimationOptions)
                     animations:^{
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];

options:
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
```

### 2.具体实现：
- 2.1 使用`UIBezierPath` ＋`CAShapeLayer`来画一段线条作为琴弦；

```
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
```

- 2.2 初始化一个`UIView`对象，用来显示`Spring Animation`的动画效果（  demo中用绿点表示）；

```
springView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x, 300, 5, 5)];
    springView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:springView];
```

- 2.3 为`self.view`添加`UIPanGestureRecognizer`手势，用来计算琴弦被拉动后的位置，当拖动琴弦的时候(`UIGestureRecognizerStateChanged`状态下)，更改贝塞尔曲线的控制点，刷新`shapeLayer.path`，使琴弦发生形变，并且更改`springView`的位置为当前手指移动的位置；

当松开琴弦时(`UIGestureRecognizerStateEnded`状态下)， 为`springView`添加`Spring Animation`动画，同时使用`CADisplayLink`对`springView`的波动位置进行**位置扫描**；

```
UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePa:)];
[self.view addGestureRecognizer:pan];

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
                                      delay:0   //延迟时间
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
```

- 2.4 使用`CADisplayLink`来捕获`Spring Animation`动画视图的位置坐标，从而刷新琴弦的曲线轨迹，使其看上去像*波动起来了*。
这里可以使用`layer.presentationLayer`来获取当前动画层的对象，然后获取当前动画层对象的**位置坐标**，进而刷新琴弦拨动曲线。

```
 CALayer *layer = _curveView.layer.presentationLayer;
 layer.position.x;
 layer.position.y;
```

```
displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(calculatePath)];
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  displayLink.paused = YES;

- (void)calculatePath
{
    CALayer *layer = springView.layer.presentationLayer;
    [self reflashShapeLayerPath:CGPointMake(layer.position.x, layer.position.y)];
}

```

这样，琴弦拨动的动画就完成了，最总效果如下：


![弹弹弹.gif](http://upload-images.jianshu.io/upload_images/670087-a3d7138fb69c3940.gif?imageMogr2/auto-orient/strip)

> OK, 写到最后脑洞一下：对这个动画demo再包装一下，加点音效，是不是就能成为一个弹弓打鸟的游戏App呢？或者古筝类的App呢？

***

Demo下载链接：[CAShapeLayerDemo](https://github.com/Kangqj/Demo/tree/master/CAShapeLayerDemo)

[@Kangqj](http://www.jianshu.com/users/1161c7b62af8/latest_articles)