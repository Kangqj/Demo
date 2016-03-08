>平时在写一些demo的过程中，想给按钮加一些背景图片，又苦于没有美工去做切图，而只设置按钮背景颜色的话又没有高亮效果，想着不如自己用代码生成一个UIImage来做，于是封装了一些UIImage的扩展类方法，直接调用即可，很方便（效果见最下面demo）。

![](http://upload-images.jianshu.io/upload_images/670087-80c9d50cef2b0bee.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
- 直角矩形

```
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
```

- 圆角矩形


```
+ (UIImage *)drawRoundRectImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //去锯齿处理
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    //切圆角
    float radius = MIN(size.width, size.height);
    
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius/5] addClip];
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
```

- 圆形

```
+ (UIImage *)drawRoundImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //去锯齿处理
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    CGContextAddArc(context, size.width/2, size.height/2, size.width/2 - 2, 0, 2*M_PI, YES);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    
    if (empty)
    {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    }
    else
    {
        CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
```

- 三角形

```
+ (UIImage *)drawRadarBottomImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //去锯齿处理
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);

    //画圆点
    CGContextAddArc(context, size.width/2, size.width/2, size.width/20, 0, 2*M_PI, YES);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    
    if (empty)
    {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    }
    else
    {
        CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] = CGPointMake(size.width/2, size.height/2 + 6);//坐标1
    sPoints[1] = CGPointMake(size.width/2 - 10, size.height-2);//坐标2
    sPoints[2] = CGPointMake(size.width/2 + 10, size.height-2);//坐标3
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextClosePath(context);//封起来
    if (empty)
    {
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    }
    else
    {
        CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    }
    
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
```

- 笑脸

```
+ (UIImage *)drawSmileFaceImageWithColor:(UIColor *)color size:(CGSize)size radius:(float)radius
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    //眼睛
    CGContextAddArc(context, size.width/3, size.width/3, size.width/15, 0, 2*M_PI, YES);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    CGContextAddArc(context, size.width*2/3, size.width/3, size.width/15, 0, 2*M_PI, YES);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    //嘴
    drawArc(color, CGPointMake(size.width/2, size.height/2), radius, 180/8, 180*7/8, NO);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 画圆弧
 CGContextAddArc(context, 圆心x, 圆心y, 半径, 开始弧度, 结束弧度, 1逆时针0顺时针);
 
 角度坐标象限示意图:
 
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
void drawArc(UIColor *color,  CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool isClockwise)
{
    //1.获得图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.绘制图形
    CGContextAddArc(context, center.x, center.y, radius, arc(startAngle), arc(endAngle), isClockwise);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);//填充颜色
    
    //3.显示
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    
    //3.显示
    CGContextStrokePath(context);//绘制路径
}
//角度转弧度
CGFloat arc(float angle)
{
    return angle*M_PI/180;
}
```

其中笑脸的眼睛为两个实心圆，嘴使用`CGContextAddArc`函数画一个圆弧，这一拼凑出一个笑脸（其实主要还是想使用一下画圆弧的这个方法^_^）

- 椭圆

```
//椭圆
+ (UIImage *)drawEllipseImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    
    //去锯齿处理
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    //绘制椭圆
    CGContextAddEllipseInRect(context, CGRectMake(2, 2, size.width-4, size.height-4));
    
    if (empty)
    {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);//填充颜色
    }
    else
    {
        CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
```

- 贝塞尔曲线

```
//贝塞尔曲线
+ (UIImage *)drawBezierLineImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    
    //绘制贝塞尔
    CGPoint fromPoint = CGPointMake(0, size.height/2);                  //起点
    CGPoint toPoint = CGPointMake(size.width, size.height/2);           //终点
    CGPoint controlPoint1 = CGPointMake(size.width/3, 0);   //控制点1
    CGPoint controlPoint2 = CGPointMake(size.width*2/3, size.height); //控制点2
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddCurveToPoint(context, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, toPoint.x, toPoint.y);
    
    if (empty)
    {
        CGContextStrokePath(context);//填充颜色
    }
    else
    {
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);//填充颜色
        CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
```

> 不定期更新补充...

***

Demo下载链接：[CategoryDemo](https://github.com/Kangqj/Demo/tree/master/CategoryDemo)

[@Kangqj](http://www.jianshu.com/users/1161c7b62af8/latest_articles)