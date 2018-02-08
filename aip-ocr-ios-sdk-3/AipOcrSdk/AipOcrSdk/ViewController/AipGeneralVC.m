//
//  AipGeneralVC.m
//  OCRLib
//  通用文字识别ViewController
//  Created by Yan,Xiangda on 2017/2/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "AipGeneralVC.h"
#import "AipCameraController.h"
#import "AipCameraPreviewView.h"
#import "AipCutImageView.h"
#import "AipNavigationController.h"
#import "AipOcrService.h"
#import "AipImageView.h"
#import <CoreMotion/CoreMotion.h>
#import "UIImage+AipCameraAddition.h"

#define MyLocal(x, ...) NSLocalizedString(x, nil)

#define V_X(v)      v.frame.origin.x
#define V_Y(v)      v.frame.origin.y
#define V_H(v)      v.frame.size.height
#define V_W(v)      v.frame.size.width

@interface AipGeneralVC () <UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AipCutImageDelegate>

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIButton *checkCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkChooseBtn;
@property (weak, nonatomic) IBOutlet UIButton *transformButton;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolViewBoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkViewBoom;
@property (weak, nonatomic) IBOutlet AipCameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet AipCutImageView *cutImageView;
@property (weak, nonatomic) IBOutlet AipImageView *maskImageView;
@property (strong, nonatomic) AipCameraController *cameraController;
@property (strong, nonatomic) CMMotionManager  *cmmotionManager;
@property (assign, nonatomic) UIDeviceOrientation curDeviceOrientation;
@property (assign, nonatomic) UIDeviceOrientation imageDeviceOrientation;
@property (assign, nonatomic) UIImageOrientation imageOrientation;
@property (assign, nonatomic) CGSize size;

@end

@implementation AipGeneralVC

#pragma mark - Lifecycle

- (void)dealloc{
    
    [self.cameraController stopRunningCamera];
    NSLog(@"♻️ Dealloc %@", NSStringFromClass([self class]));
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraController = [[AipCameraController alloc] initWithCameraPosition:AVCaptureDevicePositionBack];
    
    [self setupViews];
    [self setUpMaskImageView];
    //delegate 用做传递手势事件
    self.maskImageView.delegate = self.cutImageView;
    self.cutImageView.imgDelegate = self;
    
    self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    
    self.cmmotionManager = [[CMMotionManager alloc]init];
    
    __weak typeof(self) wself = self;
    if([self.cmmotionManager isDeviceMotionAvailable]) {
        [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            if (accelerometerData.acceleration.x >= 0.75) {//home button left
                wself.curDeviceOrientation = UIDeviceOrientationLandscapeRight;
            }
            else if (accelerometerData.acceleration.x <= -0.75) {//home button right
                wself.curDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
            else if (accelerometerData.acceleration.y <= -0.75) {
                wself.curDeviceOrientation = UIDeviceOrientationPortrait;
            }
            else if (accelerometerData.acceleration.y >= 0.75) {
                wself.curDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            }
            else {
                // Consider same as last time
                return;
            }
            
            [wself orientationChanged];
            
        }];
    }
    
    [self.cameraController startRunningCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


#pragma mark - SetUp

//还原初始值
- (void)reset{
    
    self.imageOrientation = UIImageOrientationUp;
    self.closeButton.hidden = NO;
    self.previewView.hidden = NO;
    self.cutImageView.hidden = YES;
    self.maskImageView.hidden = YES;
    self.checkViewBoom.constant = -V_H(self.checkView);
    self.toolViewBoom.constant = 0;
    //关灯
    [self OffLight];
    
    NSLog(@"reset");
}

- (void)setupViews {
    
    self.navigationController.navigationBarHidden = YES;
    
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewView.session = self.cameraController.session;
}

- (void)setUpMaskImageView {
    
    self.maskImageView.showMidLines = YES;
    self.maskImageView.needScaleCrop = YES;
    self.maskImageView.showCrossLines = YES;
    self.maskImageView.cropAreaCornerWidth = 30;
    self.maskImageView.cropAreaCornerHeight = 30;
    self.maskImageView.minSpace = 30;
    self.maskImageView.cropAreaCornerLineColor = [UIColor yellowColor];//[UIColor colorWithWhite:1 alpha:1];
    self.maskImageView.cropAreaBorderLineColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.maskImageView.cropAreaCornerLineWidth = 3;
    self.maskImageView.cropAreaBorderLineWidth = 1;
    self.maskImageView.cropAreaMidLineWidth = 30;
    self.maskImageView.cropAreaMidLineHeight = 1;
    self.maskImageView.cropAreaCrossLineColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.maskImageView.cropAreaCrossLineWidth = 1;
    self.maskImageView.cropAspectRatio = 662/1010.0;
    
}

//设置背景图
- (void)setupCutImageView:(UIImage *)image fromPhotoLib:(BOOL)isFromLib {
    
    if (isFromLib) {
        
        self.cutImageView.userInteractionEnabled = YES;
        self.transformButton.hidden = NO;
    }else{
        
        self.cutImageView.userInteractionEnabled = NO;
        self.transformButton.hidden = YES;
    }
    self.previewView.hidden = YES;
    [self.cutImageView setBGImage:image fromPhotoLib:isFromLib useGestureRecognizer:NO];
    self.cutImageView.hidden = NO;
    self.maskImageView.hidden = NO;
    self.closeButton.hidden = YES;
    self.checkViewBoom.constant = 0;
    self.toolViewBoom.constant = -V_H(self.toolsView);
}

#pragma mark - Action handling

- (IBAction)turnLight:(id)sender {
    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(![device isTorchModeSupported:AVCaptureTorchModeOn] || ![device isTorchModeSupported:AVCaptureTorchModeOff]) {
        
        //ytodo [self passport_showTextHUDWithTitle:@"暂不支持照明功能" hiddenAfterDelay:0.2];
        return;
    }
    [self.previewView.session beginConfiguration];
    [device lockForConfiguration:nil];
    if (!self.lightButton.selected) { // 照明状态
        if (device.torchMode == AVCaptureTorchModeOff) {
            // Set torch to on
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        
    }else
    {
        // Set torch to on
        [device setTorchMode:AVCaptureTorchModeOff];
    }
    self.lightButton.selected = !self.lightButton.selected;
    [device unlockForConfiguration];
    [self.previewView.session commitConfiguration];
}

- (IBAction)pressTransform:(id)sender {
    
    //向右转90'
    self.cutImageView.bgImageView.transform = CGAffineTransformRotate (self.cutImageView.bgImageView.transform, M_PI_2);
    if (self.imageOrientation == UIImageOrientationUp) {
        
        self.imageOrientation = UIImageOrientationRight;
    }else if (self.imageOrientation == UIImageOrientationRight){
        
        self.imageOrientation = UIImageOrientationDown;
    }else if (self.imageOrientation == UIImageOrientationDown){
        
        self.imageOrientation = UIImageOrientationLeft;
    }else{
        
        self.imageOrientation = UIImageOrientationUp;
    }
    
}

//上传图片识别结果
- (IBAction)pressCheckChoose:(id)sender {
    
    
    CGRect rect  = [self TransformTheRect];
    
    UIImage *cutImage = [self.cutImageView cutImageFromView:self.cutImageView.bgImageView withSize:self.size atFrame:rect];
    
    UIImage *image = [UIImage sapicamera_rotateImageEx:cutImage.CGImage byDeviceOrientation:self.imageDeviceOrientation];
    
    UIImage *finalImage = [UIImage sapicamera_rotateImageEx:image.CGImage orientation:self.imageOrientation];

    __weak __typeof (self) weakSelf = self;

    if (self.handler) {
        self.handler(finalImage, weakSelf);
    }

}


- (IBAction)pressCheckBack:(id)sender {
    
    [self reset];
}


- (IBAction)captureIDCard:(id)sender {
    
    __weak __typeof (self) weakSelf = self;
    [self.cameraController captureStillImageWithHandler:^(NSData *imageData) {
        
        
        [weakSelf setupCutImageView:[UIImage imageWithData:imageData]fromPhotoLib:YES];
    }];
}


- (IBAction)pressBackButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openPhotoAlbum:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //model 一个 View
        [self presentViewController:picker animated:YES completion:^{
            
            
        }];
    }
    else {
        NSAssert(NO, @" ");
    }
}

+ (void)resetView
{
    NSLog(@"resetView");

    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"AipOcrSdk" bundle:[NSBundle bundleForClass:[self class]]];
    AipGeneralVC *vc = [mainSB instantiateViewControllerWithIdentifier:@"AipGeneralVC"];
    
    [vc reset];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
#pragma mark - notification

#pragma mark - loadData

#pragma mark - public

+(CGFloat)speScale{
    
    return (CGFloat) (([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1);
}

+(UIViewController *)ViewControllerWithHandler:(void (^)(UIImage *image, AipGeneralVC *vc))handler {

    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"AipOcrSdk" bundle:[NSBundle bundleForClass:[self class]]];

    AipGeneralVC *vc = [mainSB instantiateViewControllerWithIdentifier:@"AipGeneralVC"];
    vc.handler = handler;

    AipNavigationController *navController = [[AipNavigationController alloc] initWithRootViewController:vc];
    return navController;
}

#pragma mark - private

//监测设备方向
- (void)orientationChanged{
    
    CGAffineTransform transform;
    
    if (self.curDeviceOrientation == UIDeviceOrientationPortrait) {
        
        transform = CGAffineTransformMakeRotation(0);
        
        self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    }else if (self.curDeviceOrientation == UIDeviceOrientationLandscapeLeft){
        
        transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.imageDeviceOrientation = UIDeviceOrientationLandscapeLeft;
    }else if (self.curDeviceOrientation == UIDeviceOrientationLandscapeRight){
        
        transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        self.imageDeviceOrientation = UIDeviceOrientationLandscapeRight;
    }else {
        
        transform = CGAffineTransformMakeRotation(0);
        
        self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.albumButton.transform = transform;
        self.closeButton.transform = transform;
        self.lightButton.transform = transform;
        self.closeButton.transform = transform;
        self.captureButton.transform = transform;
        self.checkCloseBtn.transform = transform;
        self.checkChooseBtn.transform = transform;
        self.transformButton.transform = transform;
    } completion:^(BOOL finished) {
        
        
    }];
    
    
}

- (CGRect)TransformTheRect{
    
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    
    CGFloat cropAreaViewX = V_X(self.maskImageView.cropAreaView);
    CGFloat cropAreaViewY = V_Y(self.maskImageView.cropAreaView);
    CGFloat cropAreaViewW = V_W(self.maskImageView.cropAreaView);
    CGFloat cropAreaViewH = V_H(self.maskImageView.cropAreaView);
    
    CGFloat bgImageViewX  = V_X(self.cutImageView.bgImageView);
    CGFloat bgImageViewY  = V_Y(self.cutImageView.bgImageView);
    CGFloat bgImageViewW  = V_W(self.cutImageView.bgImageView);
    CGFloat bgImageViewH  = V_H(self.cutImageView.bgImageView);
    
    if (self.imageOrientation == UIImageOrientationUp) {
        
        
        if (cropAreaViewX< bgImageViewX) {
            
            x = 0;
            width = cropAreaViewW - (bgImageViewX - cropAreaViewX);
        }else{
            
            x = cropAreaViewX-bgImageViewX;
            width = cropAreaViewW;
        }
        
        if (cropAreaViewY< bgImageViewY) {
            
            y = 0;
            height = cropAreaViewH - (bgImageViewY - cropAreaViewY);
        }else{
            
            y = cropAreaViewY-bgImageViewY;
            height = cropAreaViewH;
        }
        
        self.size = CGSizeMake(bgImageViewW, bgImageViewH);
    }else if (self.imageOrientation == UIImageOrientationRight){
        
        if (cropAreaViewY<bgImageViewY) {
            
            x = 0;
            width = cropAreaViewH - (bgImageViewY - cropAreaViewY);
        }else{
            
            x = cropAreaViewY - bgImageViewY;
            width = cropAreaViewH;
        }
        
        CGFloat newCardViewX = cropAreaViewX + cropAreaViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        if (newCardViewX>newBgImageViewX) {
            y = 0;
            height = cropAreaViewW - (newCardViewX - newBgImageViewX);
        }else{
            
            y = newBgImageViewX - newCardViewX;
            height = cropAreaViewW;
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
    }else if (self.imageOrientation == UIImageOrientationLeft){
        
        if (cropAreaViewX < bgImageViewX) {
            
            y = 0;
            height = cropAreaViewW - (bgImageViewX - cropAreaViewX);
        }else{
            
            y = cropAreaViewX-bgImageViewX;
            height = cropAreaViewW;
        }
        
        CGFloat newCardViewY = cropAreaViewY + cropAreaViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewY< newBgImageViewY) {
            
            x = newBgImageViewY - newCardViewY;
            width = cropAreaViewH;
        }else{
            
            x = 0;
            width = cropAreaViewH - (newCardViewY - newBgImageViewY);
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
    }else{
        
        CGFloat newCardViewX = cropAreaViewX + cropAreaViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        CGFloat newCardViewY = cropAreaViewY + cropAreaViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewX < newBgImageViewX) {
            
            x = newBgImageViewX - newCardViewX;
            width = cropAreaViewW;
        }else{
            
            x = 0;
            width = cropAreaViewW - (newCardViewX - newBgImageViewX);
        }
        
        if (newCardViewY < newBgImageViewY) {
            
            y = newBgImageViewY - newCardViewY;
            height = cropAreaViewH;
            
        }else{
            
            y = 0;
            height = cropAreaViewH - (newCardViewY - newBgImageViewY);
        }
        
        self.size = CGSizeMake(bgImageViewW, bgImageViewH);
    }
    
    return CGRectMake(x, y, width, height);
}

- (void)OffLight {
    if (self.lightButton.selected) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self.previewView.session beginConfiguration];
        [device lockForConfiguration:nil];
        if([device isTorchModeSupported:AVCaptureTorchModeOff]) {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
        [self.previewView.session commitConfiguration];
    }
    
    self.lightButton.selected = NO;
}

#pragma mark - dataSource && delegate

//AipCutImageDelegate

- (void)AipCutImageBeginPaint{
    
}
- (void)AipCutImageScale{
    
}
- (void)AipCutImageMove{
    
}
- (void)AipCutImageEndPaint{
    
}

//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSAssert(image, @" ");
    if (image) {
        
        [self setupCutImageView:image fromPhotoLib:YES];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

//UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - function

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
