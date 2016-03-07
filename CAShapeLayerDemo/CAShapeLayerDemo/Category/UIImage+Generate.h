//
//  UIImage+Generate.h
//  CategoryDemo
//
//  Created by 康起军 on 16/1/14.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Generate)

//直角矩形
+ (UIImage *)drawRectImageWithColor:(UIColor *)color size:(CGSize)size;

//圆角矩形
+ (UIImage *)drawRoundRectImageWithColor:(UIColor *)color size:(CGSize)size;

//圆形
+ (UIImage *)drawRoundImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty;

//三角形
+ (UIImage *)drawTriangleImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty;

//笑脸
+ (UIImage *)drawSmileFaceImageWithColor:(UIColor *)color size:(CGSize)size radius:(float)radius;

//椭圆
+ (UIImage *)drawEllipseImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty;

+ (UIImage *)drawText:(NSString *)text color:(UIColor *)color font:(UIFont *)font size:(CGSize)size;

@end
