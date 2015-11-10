//
//  UIImage_Colorful.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithCornerRadius:(float)cornerRadius image:(UIImage *)oriImage;
+ (UIImage *)createRoundImageSize:(CGSize)size color:(UIColor *)color;


@end

@implementation UIImage (colorful)

//根据颜色生成图片
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

//图片剪切
+ (UIImage *)imageWithCornerRadius:(float)cornerRadius image:(UIImage *)oriImage {
    
    CGRect frame = CGRectMake(0, 0, oriImage.size.width, oriImage.size.height);
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(oriImage.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [oriImage drawInRect:frame];
    
    // Get the image, here setting the UIImageView image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)createRoundImageSize:(CGSize)size color:(UIColor *)color
{
    CGFloat red = [UIColor redValueFrom:color];
    CGFloat green = [UIColor greenValueFrom:color];
    CGFloat blue = [UIColor blueValueFrom:color];
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, red, green, blue, 1.0);
    
    CGContextSetLineWidth(context, 5.0);
    CGContextAddArc(context, size.width/2.0f, size.height/2.0f, size.width/2.0f - 5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
