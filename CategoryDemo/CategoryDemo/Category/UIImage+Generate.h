//
//  UIImage+Generate.h
//  CategoryDemo
//
//  Created by 康起军 on 16/1/14.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Generate)

+ (UIImage *)drawRectImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRoundImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRoundRectImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawRadarBottomImageWithColor:(UIColor *)color size:(CGSize)size isEmpty:(BOOL)empty;


@end
