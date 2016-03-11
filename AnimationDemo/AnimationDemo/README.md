> 经常使用支付宝结账，发现支付成功后，都会有个画圈打勾的动画效果，所以想着：咱也试着写一个呗～

![](http://upload-images.jianshu.io/upload_images/670087-374cbb9c803d5d2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 实现方案：

1. 绘制一个圆圈路径；
2. 绘制一个对勾的路径；
3. 添加动画效果实现。

### 使用到的技术点
- `CAShapeLayer`;
- `UIBezierPath`;
- `CABasicAnimation`;

### 具体实现

1.路径绘制，使用贝塞尔曲线来画一个圆圈（注意启示弧度和终点弧度的设置），对勾可以用两条直线来拼接，这也可以用贝塞尔曲线来画；

```
    //圆圈路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(60, 200) radius:50 startAngle:M_PI * 3 / 2 endAngle:M_PI * 7 / 2 clockwise:YES];
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    
    //对勾路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(30, 200)];
    [linePath addLineToPoint:CGPointMake(60, 220)];
    [linePath addLineToPoint:CGPointMake(90, 190)];

    //拼接两个路径
    [path appendPath:linePath];
```

2.由于`CAShapeLayer `的path属性只能赋值一个路径，那我又两个路径怎么办呢？
答案是可以使用下面方法将两个路径拼接起来：

```
// Appending paths
- (void)appendPath:(UIBezierPath *)bezierPath;
```

3.初始化`CAShapeLayer `，定义线条颜色，宽度；

```
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor greenColor].CGColor;//线条颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色
    shapeLayer.lineWidth = 5.0;
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 0.0;
    [self.view.layer addSublayer:shapeLayer];
```
`strokeStart，strokeEnd`官方文档的解释如下：

```
/* These values define the subregion of the path used to draw the
 * stroked outline. The values must be in the range [0,1] with zero
 * representing the start of the path and one the end. Values in
 * between zero and one are interpolated linearly along the path
 * length. strokeStart defaults to zero and strokeEnd to one. Both are
 * animatable. */
```

大致意思是：用这两个属性来定义要绘制的路径的区域范围，取值范围为0到1，代表着路径的开始和结束，两个属性默认都是0，可以用来做一些动画效果。
说的通俗点（翻译成人话），这两个值其实就是定义要绘制路径的区域的某一段，比如`strokeStart＝0，strokeEnd=0.25 `，就代表着绘制路径的前1/4段；同理，`strokeStart＝0.75，strokeEnd=1.0 `，就是绘制路径的后1/4段；

4.给`CAShapeLayer `添加`CABasicAnimation`动画，动画根据`strokeEnd`的值的变化来进行，动画结束后，由于需要保持动画的最后状态（也就是`strokeEnd＝1`的状态），所以需要设置：

```
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
```

5.这样完整的动画就出现来了，逆向动画的实现方法也很简单，在动画结束后
重新设置`strokeEnd = 1.0`，再进行动画事件就可以了。
（具体动画效果见Demo）

```
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
```

> `CAShapeLayer + UIBezierPath` 可以实现很多其它有意思的动画效果，后面继续研究...


***

Demo下载链接：[AnimationDemo](https://github.com/Kangqj/Demo/tree/master/AnimationDemo)

[@Kangqj](http://www.jianshu.com/users/1161c7b62af8/latest_articles)