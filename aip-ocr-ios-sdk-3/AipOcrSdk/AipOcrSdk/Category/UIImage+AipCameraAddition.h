//
//  UIImage+AipCameraAddition.h
//  AipOcrSdk
//
//  Created by Yan,Xiangda on 2017/4/13.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (AipCameraAddition)

+ (UIImage *)sapicamera_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (UIImage *)sapicamera_imageCropRect:(CGRect)rect;

- (UIImage *)sapicamera_imageScaledToSize:(CGSize)newSize;

- (UIImage *)sapicamera_fixOrientation;

+ (UIImage *)sapicamera_rotateImageEx:(CGImageRef)imgRef byDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

+ (UIImage *)sapicamera_rotateImageEx:(CGImageRef)imgRef orientation:(UIImageOrientation) orient;

@end
