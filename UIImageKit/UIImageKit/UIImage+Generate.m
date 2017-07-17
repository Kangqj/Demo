//
//  UIImage+Generate.m
//  CategoryDemo
//
//  Created by 康起军 on 16/1/14.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "UIImage+Generate.h"

@implementation UIImage (Generate)

//画一个直角矩形图片
+ (UIImage *)drawRectImageWithColor:(UIColor *)color size:(CGSize)size
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

//画一个圆角矩形图片
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

//画一个圆形图片
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

//三角形
+ (UIImage *)drawTriangleImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty
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

//笑脸
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

+ (UIImage *)drawText:(NSString *)text color:(UIColor *)color font:(UIFont *)font size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    CGContextSetFillColorWithColor(context, color.CGColor);
//    [text drawAtPoint:CGPointMake(100, 100) withAttributes:attributes];
    [text drawInRect:CGRectMake(50, 50, size.width-100, size.height-100) withAttributes:attributes];

//    [text drawInRect: CGRectMake(0, 0, size.width, size.height)
//     
//              withFont: font
//     
//         lineBreakMode: NSLineBreakByClipping
//     
//             alignment: NSTextAlignmentLeft];
    
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 画圆弧,圆
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
void drawArc(UIColor *color,  CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool isClockwise)
{
    //1.获得图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.绘制图形
    CGContextAddArc(context, center.x, center.y, radius, arc(startAngle), arc(endAngle), isClockwise);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);//填充颜色
    
    //3.显示
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    
    //3.显示
    CGContextStrokePath(context);//绘制路径
}
//角度转弧度
CGFloat arc(float angle)
{
    return angle*M_PI/180;
}

@end
