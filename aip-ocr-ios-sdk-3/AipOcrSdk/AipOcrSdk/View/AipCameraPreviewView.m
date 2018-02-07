//
//  AipCameraPreviewView.m
//  SAPICameraLib
//
//  Created by jiangzhenjie on 16/6/7.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import "AipCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AipCameraPreviewView

@synthesize session = _session;

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.session = session;
}

- (void)dealloc {
    _session = nil;
}

@end
