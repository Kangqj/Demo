//
//  AipCameraController.m
//  SAPICameraLib
//
//  Created by jiangzhenjie on 16/5/26.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import "AipCameraController.h"

@interface AipCameraController() <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *backCameraDevice;
@property (nonatomic, strong) AVCaptureDevice *frontCameraDevice;

@property (nonatomic, strong) AVCaptureDeviceInput *currentDeviceInput;

@property (nonatomic, strong, readonly) AVCaptureDevice *currentCameraDevice;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end

@implementation AipCameraController

#pragma mark - Initial
- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position {
    self = [super init];
    if (self) {
        _cameraPosition = position;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<AipCameraDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _cameraPosition = AVCaptureDevicePositionBack;
        [self commonInit];
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

- (void)commonInit {
 
    [self configureCamera];
    [self requestPermission];
    
}

#pragma mark - Request permission
- (void)requestPermission {
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        AVAuthorizationStatus status =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:didChangeAuthorizationStatus:)]) {
                            [self.delegate cameraController:self didChangeAuthorizationStatus:AVAuthorizationStatusAuthorized];
                        }
                        
                    } else {
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:didChangeAuthorizationStatus:)]) {
                            [self.delegate cameraController:self didChangeAuthorizationStatus:AVAuthorizationStatusDenied];
                        }
                        
                    }
                }];
                break;
            }
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied: {
                NSLog(@"未授权访问相机");
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                break;
            }
        }
        
    }
}

#pragma mark - Configure
- (void)configureCamera {
    
    self.session = [[AVCaptureSession alloc] init];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
#if !TARGET_IPHONE_SIMULATOR
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
#endif
    }
    
    self.sessionQueue = dispatch_queue_create("com.baidu.passport.cameraSessionQueue", DISPATCH_QUEUE_SERIAL);
    
    [self executeSessionConfiguration:^{
        [self configureDeviceInput];
        [self configureStillImageCameraOutput];
        [self configureFaceDetection];
        [self configureVideoOutput];
    }];
    
}

- (void)configureDeviceInput {
    
    NSError *error = nil;
    self.currentDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.currentCameraDevice error:&error];
    if (!error && self.currentDeviceInput) {
        if ([self.session canAddInput:self.currentDeviceInput]) {
            [self.session addInput:self.currentDeviceInput];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:didCatchError:)]) {
            [self.delegate cameraController:self didCatchError:error];
        }
    }
    
}

- (void)configureStillImageCameraOutput {
    
    self.stillCameraOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillCameraOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG,
                                              AVVideoQualityKey : @(0.9)};
    if ([self.session canAddOutput:self.stillCameraOutput]) {
        [self.session addOutput:self.stillCameraOutput];
    }
    
}

- (void)configureVideoOutput {
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("com.baidu.passport.cameraSampleBuffer", DISPATCH_QUEUE_SERIAL)];
    
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
}

- (void)configureFaceDetection {
    
//    [self executeAction:^{
//        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
//        [self.metadataOutput setMetadataObjectsDelegate:self queue:self.sessionQueue];
//        
//        if ([self.session canAddOutput:self.metadataOutput]) {
//            [self.session addOutput:self.metadataOutput];
//        }
//        
//        if ([self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace]) {
//            self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
//        }
//    }];
    
}

#pragma mark - Public methods
- (void)startRunningCamera {
    
    if (!self.session) {
        return;
    }
    
    [self executeAction:^{
#if !TARGET_IPHONE_SIMULATOR
        [self.session startRunning];
#endif
        
    }];
    
}

- (void)stopRunningCamera {
    
    if (!self.session) {
        return;
    }
    
    [self executeAction:^{
#if !TARGET_IPHONE_SIMULATOR
        [self.session stopRunning];
#endif
        
    }];
    
}

- (void)switchCamera {
    
    //TODO: 快速点击的时候会出现不可用
    
    [self executeAction:^{
        
        switch (self.cameraPosition) {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionBack: {
                _cameraPosition = AVCaptureDevicePositionFront;
                break;
            }
            case AVCaptureDevicePositionFront: {
                _cameraPosition = AVCaptureDevicePositionBack;
                break;
            }
        }
        
        [self.session removeInput:self.currentDeviceInput];
        
        [self configureDeviceInput];
        
    }];
    
}

- (void)captureStillImageWithHandler:(void (^)(NSData *))handler {
    
    [self captureStillImageWithHandler:handler afterDelay:0];
    
}

- (void)captureStillImageWithHandler:(void (^)(NSData *))handler afterDelay:(NSTimeInterval)delay {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.sessionQueue, ^{
        
        AVCaptureConnection *connection = [self.stillCameraOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.stillCameraOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (error == nil) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                handler(imageData);
            } else {
                handler(nil);
            }
            
        }];
        
    });
    
}

- (void)autofocusOnce:(CGPoint)point {
    [self executeCameraConfiguration:^{
        if (self.currentCameraDevice.isFocusPointOfInterestSupported) {
            self.currentCameraDevice.focusPointOfInterest = point;
            self.currentCameraDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }
    }];
    [self performSelector:@selector(resumeContinuousAutofocusing) withObject:nil afterDelay:0.1f];
}

- (void)resumeContinuousAutofocusing {
    [self executeCameraConfiguration:^{
        if ([self.currentCameraDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            self.currentCameraDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
    }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
    
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
//    
//    if (metadataObjects.count != 0) {
//        
//        AVMetadataFaceObject *faceObj = [metadataObjects firstObject];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:didDetectFace:)]) {
//            [self.delegate cameraController:self didDetectFace:faceObj];
//        }
//        
//    }
//    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputMetadataObjects:fromConnection:)]) {
//        [self.delegate captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
//    }
//    
//}

#pragma mark - Utility
- (void)executeAction:(void(^)(void))action {
    
    if (!self.sessionQueue) {
        return;
    }
    
    dispatch_async(self.sessionQueue, ^{
        action();
    });
}

- (void)executeSessionConfiguration:(void(^)(void))action {
    
    if (!self.sessionQueue) {
        return;
    }
    
    dispatch_async(self.sessionQueue, ^{
        
        [self.session beginConfiguration];
        action();
#if !TARGET_IPHONE_SIMULATOR
        [self.session commitConfiguration];
#endif
        
        
    });
    
}

- (void)executeCameraConfiguration:(void(^)(void))action {
    
    if (!self.sessionQueue) {
        return;
    }
    
    dispatch_async(self.sessionQueue, ^{
        
        NSError *error = nil;
        if ([self.currentCameraDevice lockForConfiguration:&error]) {
            action();
            [self.currentCameraDevice unlockForConfiguration];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraController:didCatchError:)]) {
                [self.delegate cameraController:self didCatchError:error];
            }
        }
        
    });
    
}

#pragma mark - Property
- (AVCaptureDevice *)currentCameraDevice {
    
    switch (self.cameraPosition) {
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionBack: {
            return self.backCameraDevice;
        }
        case AVCaptureDevicePositionFront: {
            return self.frontCameraDevice;
        }
    }
    
}

- (AVCaptureDevice *)backCameraDevice {
    
    if (!_backCameraDevice) {
        
        NSArray *availableCameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in availableCameraDevices) {
            if (device.position == AVCaptureDevicePositionBack) {
                _backCameraDevice = device;
            } else if (device.position == AVCaptureDevicePositionFront) {
                _frontCameraDevice = device;
            }
        }
        
    }
    
    return _backCameraDevice;
}

- (AVCaptureDevice *)frontCameraDevice {
    
    if (!_frontCameraDevice) {
        
        NSArray *availableCameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for (AVCaptureDevice *device in availableCameraDevices) {
            if (device.position == AVCaptureDevicePositionBack) {
                _backCameraDevice = device;
            } else if (device.position == AVCaptureDevicePositionFront) {
                _frontCameraDevice = device;
            }
        }
        
    }
    
    return _frontCameraDevice;
}

#pragma mark - Memory manage
- (void)dealloc {
    
#if !TARGET_IPHONE_SIMULATOR
    [_session stopRunning];
#endif
    
    [_session removeInput:_currentDeviceInput];
    [_session removeOutput:_videoOutput];
    [_session removeOutput:_stillCameraOutput];
//    NSLog(@"AipCameraController dealloc");
}

@end


