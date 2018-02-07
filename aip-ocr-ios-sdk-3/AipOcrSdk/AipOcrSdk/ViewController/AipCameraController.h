//
//  AipCameraController.h
//  SAPICameraLib
//
//  Created by jiangzhenjie on 16/5/26.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AipCameraController;

@protocol AipCameraDelegate <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@optional
- (void)cameraController:(AipCameraController *)controller didChangeAuthorizationStatus:(AVAuthorizationStatus)status NS_AVAILABLE_IOS(7_0);

- (void)cameraController:(AipCameraController *)controller didCatchError:(NSError *)error;

- (void)cameraController:(AipCameraController *)controller didDetectFace:(AVMetadataFaceObject *)faceObject;

@end

@interface AipCameraController : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillCameraOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@property (nonatomic, weak) id<AipCameraDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position;

- (instancetype)initWithDelegate:(id<AipCameraDelegate>)delegate;

- (void)startRunningCamera;

- (void)stopRunningCamera;

- (void)switchCamera;

- (void)captureStillImageWithHandler:(void(^)(NSData *imageData))handler;

- (void)captureStillImageWithHandler:(void(^)(NSData *imageData))handler afterDelay:(NSTimeInterval)delay;

- (void)autofocusOnce:(CGPoint)point;

@end
