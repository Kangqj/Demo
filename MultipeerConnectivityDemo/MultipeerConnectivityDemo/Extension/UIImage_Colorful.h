//
//  UIImage_Colorful.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithCornerRadius:(float)cornerRadius image:(UIImage *)oriImage;

@end

@implementation UIImage (colorful)

//根据颜色生成图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 100, 100);
    
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


@end
