//
//  UIImage_Colorful.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (colorful)

+ (UIImage *)drawRectImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRoundImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRoundRectImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRadarBottomImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty;

@end

@implementation UIImage (colorful)

//画一个圆形图片
+ (UIImage *)drawRoundImageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //去锯齿处理
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    //2.绘制图形
    CGContextAddArc(context, size.width/2, size.height/2, size.width/2 - 2, 0, 2*M_PI, YES);
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线条颜色
    CGContextSetLineWidth(context, 2);//线条宽度
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    
    //3.显示
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径加填充
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

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

//画雷达底座
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
    
    //3.显示
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

@end
