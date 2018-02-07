//
//  AipCameraPreviewView.h
//  SAPICameraLib
//
//  Created by jiangzhenjie on 16/6/7.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface AipCameraPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *session;

@end
