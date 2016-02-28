//
//  RadarView.m
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/7.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import "RadarView.h"

@implementation RadarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [button addTarget:self action:@selector(radarRun:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage drawRadarBottomImageWithColor:[UIColor orangeColor] size:button.frame.size isEmpty:NO] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage drawRadarBottomImageWithColor:[UIColor orangeColor] size:button.frame.size isEmpty:YES] forState:UIControlStateSelected];
        [self addSubview:button];
        button.selected = NO;
        
        layerArr = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)radarRun:(UIButton *)btn
{
    if (btn.selected == YES)
    {
        [self start];
    }
    else
    {
        [self stop];
    }
    
    btn.selected = !btn.selected;
}

- (void)start
{
    if (layerArr.count == 0)
    {
        float radius = self.frame.size.width/2;
        
        NSArray *paramArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:radius/3.0],[NSNumber numberWithFloat:1.0], nil];
        [self performSelector:@selector(drawRipple:) withObject:paramArr afterDelay:0.3];
        
        paramArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:radius*2/3.0],[NSNumber numberWithFloat:2.0/3], nil];
        [self performSelector:@selector(drawRipple:) withObject:paramArr afterDelay:0.6];
        
        paramArr = [NSArray arrayWithObjects:[NSNumber numberWithFloat:radius],[NSNumber numberWithFloat:1.0/3], nil];
        [self performSelector:@selector(drawRipple:) withObject:paramArr afterDelay:0.9];
    }
    
}

- (void)stop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];//取消全部延迟函数
    
    if (layerArr.count > 0)
    {
        for (CAShapeLayer *solidLine in layerArr)
        {
            [solidLine removeFromSuperlayer];
        }
        [layerArr removeAllObjects];
    }
}

- (void)drawRipple:(NSArray *)paramArr
{
    NSNumber *radius = [paramArr objectAtIndex:0];     //弧度
    NSNumber *endOpacity = [paramArr objectAtIndex:1]; //结束透明度
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:[radius floatValue] startAngle:arc(45) endAngle:arc(135) clockwise:NO];
    
    CAShapeLayer *solidLine =  [CAShapeLayer layer];
    solidLine.lineWidth = 2.0f ;
    solidLine.strokeColor = [UIColor orangeColor].CGColor; //线条颜色
    solidLine.fillColor = [UIColor clearColor].CGColor;    //填充颜色
    solidLine.path = path.CGPath;                          //绘制路径
    solidLine.lineCap = kCALineCapRound;                   //端点圆角处理
    [self.layer addSublayer:solidLine];
    solidLine.opacity = 0;                                 //透明度
    [layerArr addObject:solidLine];
    
    float endValue = 1.0 - [radius floatValue]/(self.frame.size.width/2);
    
    if (endValue == 0)
    {
        endValue = 1.0/3;
    }
    
    CABasicAnimation *strokeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    strokeAnim.fromValue         = [NSNumber numberWithFloat:0.0];
    strokeAnim.toValue           = endOpacity;
    strokeAnim.duration          = 1;
    strokeAnim.repeatCount       = FLT_MAX;       //重复次数，无数次
    strokeAnim.autoreverses      = YES;           //动画结束后，是否执行动画回到初始状态
    strokeAnim.removedOnCompletion = NO;
    strokeAnim.fillMode = kCAFillModeForwards;
    [solidLine addAnimation:strokeAnim forKey:@"animateOpacity"];
    
    /*
     fillMode的作用就是决定当前对象过了非active时间段的行为. 比如动画开始之前,动画结束之后。如果是一个动画CAAnimation,则需要将其removedOnCompletion设置为NO,要不然fillMode不起作用.
     
     下面来讲各个fillMode的意义
     kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
     kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态
     kCAFillModeBackwards 这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
     kCAFillModeBoth 理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.
     */
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    float radius = self.frame.size.width/20;
//    drawArc(CGPointMake(self.frame.size.width/2, self.frame.size.height/2), radius, 0, 360, NO);
//    
//    [self drawTriangle];
}

/*
 画圆弧,圆
 CGContextAddArc(context, 圆心x, 圆心y, 半径, 开始弧度, 结束弧度, 1逆时针0顺时针);
 
 角度坐标示意图:
 
        PI*3/2
          |
          |
          |
PI _______|_______ 0
          |
          |
          |
        PI/2
 
 */
void drawArc(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool isClockwise)
{
    //1.获得图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.绘制图形
    CGContextAddArc(context, center.x, center.y, radius, arc(startAngle), arc(endAngle), isClockwise);
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);//填充颜色
    
    //3.显示
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    
    //3.显示
//    CGContextStrokePath(context);//绘制路径
}
//角度转弧度
CGFloat arc(float angle)
{
    return angle*M_PI/180;
}

/*
 画三角形
 */

- (void)drawTriangle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //只要三个点就行跟画一条线方式一样，把三点连接起来
    CGPoint sPoints[3];//坐标点
    sPoints[0] = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 6);//坐标1
    sPoints[1] = CGPointMake(self.frame.size.width/2 - 10, self.frame.size.height-2);//坐标2
    sPoints[2] = CGPointMake(self.frame.size.width/2 + 10, self.frame.size.height-2);//坐标3
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);//线条颜色
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextClosePath(context);//封起来
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}



@end
