//
//  UIImage+Modifications.m
//  PuzzleDemo
//
//  Created by coverme on 16/1/12.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import "UIImage+Modifications.h"

@implementation UIImage (Modifications)

- (UIImage*)cutImageView:(UIView *)view frame:(CGRect)rect
{
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return image;
}

@end
