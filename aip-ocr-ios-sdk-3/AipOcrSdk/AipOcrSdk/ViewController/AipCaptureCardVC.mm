//
//  AipCaptureCardVC.m
//  OCRLib
//
//  Created by Yan,Xiangda on 16/11/9.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import "AipCaptureCardVC.h"
#import "AipCameraController.h"
#import "AipCameraPreviewView.h"
#import "AipCutImageView.h"
#import "AipNavigationController.h"
#import "AipOcrService.h"
#if !TARGET_IPHONE_SIMULATOR
#import <IdcardQuality/IdcardQuality.h>
#endif
#import "UIImage+AipCameraAddition.h"
#import "AipDisplayLink.h"
#import <CoreMotion/CoreMotion.h>


#define MyLocal(x, ...) NSLocalizedString(x, nil)

#define V_X(v)      v.frame.origin.x
#define V_Y(v)      v.frame.origin.y
#define V_H(v)      v.frame.size.height
#define V_W(v)      v.frame.size.width

static const NSInteger bankCardViewCornerRadius = 14;
// 扫描频率的系数
static const NSInteger timeNum = 100;
// 图片拓边处理的系数
static const CGFloat cardScale = 0.02;

@interface AipCaptureCardVC () <UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AipCutImageDelegate,AipCameraDelegate,AipDisplayLinkDelegate>

@property (weak, nonatomic) IBOutlet UIView *bankCardView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIButton *checkCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkChooseBtn;
@property (weak, nonatomic) IBOutlet UIButton *transformButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolViewBoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkViewBoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipsLabelCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipsLabelCenterY;
@property (weak, nonatomic) IBOutlet UIImageView *emblemImageView;
@property (weak, nonatomic) IBOutlet UIImageView *peopleImageView;
@property (weak, nonatomic) IBOutlet AipCutImageView *cutImageView;
@property (weak, nonatomic) IBOutlet AipCameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Indicator;
@property (strong, nonatomic) AipCameraController *cameraController;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
#if !TARGET_IPHONE_SIMULATOR
@property (strong, nonatomic) IdcardQualityAdaptor *idcard;
#endif
@property (strong, nonatomic) AipDisplayLink *displaylink;
@property (strong, nonatomic) dispatch_semaphore_t sema;
@property (strong, nonatomic) UIImage *finalImage;
@property (strong, nonatomic) CMMotionManager  *cmmotionManager;
@property (assign, nonatomic) UIDeviceOrientation curDeviceOrientation;
@property (assign, nonatomic) UIDeviceOrientation imageDeviceOrientation;
@property (assign, nonatomic) UIImageOrientation imageOrientation;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) long long x;
@property (assign, nonatomic) BOOL recognizedSucceed;
@property (assign, nonatomic) BOOL displaylinkisOn;
@property (assign, nonatomic) CardType cardTypeFromVC;//记录CardType状态

@end

@implementation AipCaptureCardVC

// 集成时注意！！！ AipCaptureCardVC类使用了GCD用做扫描帧时的处理，改动本类的代码逻辑时，页面释放前一定要保证GCD信号量的正常释放，
// 参考：1.dispatch_semaphore_signal(_sema);2.self.recognizedSucceed = NO;

#pragma mark - Lifecycle

- (void)dealloc{
    
    [self.cameraController stopRunningCamera];
    [self.displaylink stop];
    NSLog(@"♻️ Dealloc %@", NSStringFromClass([self class]));
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraController = [[AipCameraController alloc] initWithCameraPosition:AVCaptureDevicePositionBack];
    
    [self setupViews];
    
    [self setupWithCardType];
    
    self.cardTypeFromVC = self.cardType;
    
    self.shapeLayer = [CAShapeLayer layer];
    [self.backgroundView.layer addSublayer:self.shapeLayer];
    
    self.cutImageView.imgDelegate = self;
    //卡片类的图片，可以适当降低图片质量，提高识别速度。
    self.cutImageView.scale = 1.2;
    
    self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    
    [self setupIdcardQuality];
    
    [self setupCmmotionManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self setupShapeLayer];

    [self.cameraController startRunningCamera];
    
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
    self.checkViewBoom.constant = -V_H(self.checkView);
    self.toolViewBoom.constant = 0;
    [self shapeLayerChangeLight];
    [self setupWithCardType]; 
    //关灯
    [self OffLight];
}

//利用陀螺仪判断设备方向
- (void)setupCmmotionManager{
    
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
}

//初始化身份证质量控制模块
- (void)setupIdcardQuality{
    
    __weak typeof(self) wself = self;
    self.recognizedSucceed = YES;
    
    if (self.cardType == CardTypeLocalIdCardFont ||
        self.cardType == CardTypeLocalIdCardBack) {
        
#if !TARGET_IPHONE_SIMULATOR
        self.idcard = [[IdcardQualityAdaptor alloc]init];
#endif
        //token 也可以在AppDelegate时获取
        [[AipOcrService shardService]getTokenSuccessHandler:^(NSString *token) {
            
#if !TARGET_IPHONE_SIMULATOR
            [wself.idcard initWithToken:token];
#endif
            [wself.displaylink start];
            wself.recognizedSucceed = NO;
        } failHandler:^(NSError *error) {
            NSLog(@"%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.tipsLabel.text = @"初始化失败：无权限";
            });
            
        }];
        
    }else{
        
        [self.displaylink start];
        self.recognizedSucceed = NO;
    }
}

- (void)setupViews {
    
    self.navigationController.navigationBarHidden = YES;
    
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewView.session = self.cameraController.session;
    
    self.bankCardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bankCardView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bankCardView.layer.borderWidth = 1.0;
    self.bankCardView.layer.cornerRadius = bankCardViewCornerRadius *[self.class speScale];
}

- (void)setupWithCardType{
    
    self.cameraController.delegate = nil;
    self.displaylink = nil;
    self.captureButton.hidden = NO;
    
    switch (self.cardType) {

        case CardTypeIdCardFont:
        {
            self.peopleImageView.hidden = NO;
            self.emblemImageView.hidden = YES;
            self.tipsLabel.text = MyLocal(@"对齐身份证正面");
        }
            break;
        case CardTypeLocalIdCardFont:
        {
            self.peopleImageView.hidden = NO;
            self.emblemImageView.hidden = YES;
            self.captureButton.hidden = YES;
            self.tipsLabel.text = MyLocal(@"对齐身份证正面");
            self.cameraController.delegate = self;
            self.displaylink = [AipDisplayLink displayLinkWithDelegate:self];
        }
            break;
        case CardTypeIdCardBack:
        {
            self.peopleImageView.hidden = YES;
            self.emblemImageView.hidden = NO;
            self.tipsLabel.text = MyLocal(@"对齐身份证背面");
        }
            break;
        case CardTypeLocalIdCardBack:
        {
            self.peopleImageView.hidden = YES;
            self.emblemImageView.hidden = NO;
            self.captureButton.hidden = YES;
            self.tipsLabel.text = MyLocal(@"对齐身份证背面");
            self.cameraController.delegate = self;
            self.displaylink = [AipDisplayLink displayLinkWithDelegate:self];
        }
            break;
        case CardTypeBankCard:
        {
            self.peopleImageView.hidden = YES;
            self.emblemImageView.hidden = YES;
            self.tipsLabel.text = MyLocal(@"对齐银行卡正面");
        }
            break;
        default:
            break;
    }
}

- (void)setupShapeLayer{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:self.bankCardView.frame cornerRadius:bankCardViewCornerRadius *[self.class speScale]] bezierPathByReversingPath]];
    [self shapeLayerChangeLight];
    self.shapeLayer.path = path.CGPath;
}

- (void)setupCutImageView:(UIImage *)image fromPhotoLib:(BOOL)isFromLib {
    
    if (isFromLib) {
        
        self.cutImageView.userInteractionEnabled = YES;
        self.transformButton.hidden = NO;
        [self.cutImageView setBGImage:image fromPhotoLib:isFromLib useGestureRecognizer:YES];
    }else{
        
        self.cutImageView.userInteractionEnabled = NO;
        self.transformButton.hidden = YES;
        [self.cutImageView setBGImage:image fromPhotoLib:isFromLib useGestureRecognizer:NO];
    }
    //关灯
    [self OffLight];
    self.previewView.hidden = YES;
    self.closeButton.hidden = YES;
    self.cutImageView.hidden = NO;
    self.checkViewBoom.constant = 0;
    self.toolViewBoom.constant = -V_H(self.toolsView);
    [self shapeLayerChangeDark];
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
    
    self.tipsLabel.text = MyLocal(@"识别中...");
    
    if (!self.cutImageView.bgImageView) {
        
        NSAssert(self.cutImageView.bgImageView, @" ");
        return;
    }
    
    
    UIImage *cutImage = [self.cutImageView cutImageFromView:self.cutImageView.bgImageView withSize:self.size atFrame:rect];
    
    UIImage *image = [UIImage sapicamera_rotateImageEx:cutImage.CGImage byDeviceOrientation:self.imageDeviceOrientation];
    
    self.finalImage = [UIImage sapicamera_rotateImageEx:image.CGImage orientation:self.imageOrientation];
    
    switch (self.cardType) {
        case CardTypeIdCardFont:{
            if(self.handler){
                self.handler(self.finalImage);
            }
            break;
        }
            
        case CardTypeIdCardBack: {
            if(self.handler){
                self.handler(self.finalImage);
            }
        }
            break;
        case CardTypeBankCard: {
            if(self.handler){
                self.handler(self.finalImage);
            }
        }
            break;
        case CardTypeLocalIdCardFont:{
            
            [self detectLocalIdcard:NO];
        }
            break;
        case CardTypeLocalIdCardBack:{
            
            [self detectLocalIdcard:YES];
        }
            break;
        case CardTypeLocalBankCard:{
            
            
        }
            break;
            
        default:
            break;
    }
    
    //还原cardType
    if (self.cardType != self.cardTypeFromVC) {
        self.cardType = self.cardTypeFromVC;
    }
    
}


- (IBAction)pressCheckBack:(id)sender {
    
    [self reset];
    [self.displaylink start];
    self.recognizedSucceed = NO;
}


- (IBAction)captureIDCard:(id)sender {
    
    __weak __typeof (self) weakSelf = self;
    [self.cameraController captureStillImageWithHandler:^(NSData *imageData) {
        
        
        [weakSelf setupCutImageView:[UIImage imageWithData:imageData]fromPhotoLib:NO];
    }];
}


- (IBAction)pressBackButton:(id)sender {
    
    if (self.cardType == CardTypeLocalIdCardFont ||self.cardType == CardTypeLocalIdCardBack) {
        
        self.recognizedSucceed = NO;
        if (_sema) {
            dispatch_semaphore_signal(_sema);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openPhotoAlbum:(id)sender {
    
    [self.displaylink stop];
    self.recognizedSucceed = YES;
    
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

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
#pragma mark - notification


#pragma mark - loadData

#pragma mark - public

+(CGFloat)speScale{
    
    return ([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1;
}

+(UIViewController *)ViewControllerWithCardType:(CardType)type andImageHandler:(void (^)(UIImage *image))handler {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"AipOcrSdk" bundle:[NSBundle bundleForClass:[self class]]];
    AipCaptureCardVC *vc = [mainSB instantiateViewControllerWithIdentifier:@"AipCaptureCardVC"];

    vc.cardType = type;
    vc.handler = handler;

    AipNavigationController *navController = [[AipNavigationController alloc] initWithRootViewController:vc];
    return navController;
}

#pragma mark - private

//监测设备方向
- (void)orientationChanged{
    
    CGAffineTransform transform;
    
    if(self.curDeviceOrientation == UIDeviceOrientationLandscapeLeft){
        
        transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.tipsLabelCenterX.constant = -140*[self.class speScale];
        self.tipsLabelCenterY.constant = -80*[self.class speScale];
        self.imageDeviceOrientation = UIDeviceOrientationLandscapeLeft;
    }else {
        
        transform = CGAffineTransformMakeRotation(0);
        
        self.tipsLabelCenterX.constant = 0;
        self.tipsLabelCenterY.constant = 100*[self.class speScale];
        self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    }
    
    self.tipsLabel.transform = transform;
    self.bankCardView.transform = transform;
    
    //重置shapeLayer
    [self setupShapeLayer];
    
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


- (void)detectLocalIdcard:(BOOL)isBack{
    NSLog(@"Detect....");
#if !TARGET_IPHONE_SIMULATOR
    IdcardQualityModel *model;
    if (isBack) {
        
        model = [self.idcard process:self.finalImage width:self.finalImage.size.width height:self.finalImage.size.height channel:3 cardType:(idcard_quality::IDCARD_BACK_SIDE)];
    }else{
        
        model = [self.idcard process:self.finalImage width:self.finalImage.size.width height:self.finalImage.size.height channel:3 cardType:(idcard_quality::IDCARD_FRONT_SIDE)];
    }
    
    if (model.errorType == 0) {
        
        self.tipsLabel.text = MyLocal(@"初始化成功：");
        
    }else{

        self.tipsLabel.text = MyLocal(@"初始化错误状态:%u",model.errorType);
        return ;
        
    }
    
    NSString *tips ;
    switch (model.image_status) {
            
        case idcard_quality::IDCARD_MOVING:{
            
            tips = [NSString stringWithFormat:@"请拿稳镜头和身份证"];
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_TOO_SMALL:{
            
            tips = [NSString stringWithFormat:@"请将镜头靠近身份证"];
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_WRONG_LOCATION:{
            
            tips = [NSString stringWithFormat:@"请将身份证完整置于取景框内"];
            dispatch_semaphore_signal(_sema);
            break;
        }
            
        case idcard_quality::IDCARD_REVERSED_SIDE:{
            
            if (isBack) {
                
                tips = [NSString stringWithFormat:@"请将身份证前后反转再进行识别"];
            }else{
                
                tips = [NSString stringWithFormat:@"请将身份证前后反转再进行识别"];
            }
            
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_OVER_EXPOSURE:{
            tips = [NSString stringWithFormat:@"身份证反光，请重新尝试"];
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_BLURRED:{
            
            tips = [NSString stringWithFormat:@"身份证模糊，请重新尝试"];
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_INCOMPLETE:{
            
            tips = [NSString stringWithFormat:@"请将身份证边缘移入框内"];
            dispatch_semaphore_signal(_sema);
            break;
        }
        case idcard_quality::IDCARD_NORMAL:{
            
            self.Indicator.hidden = NO;
            [self.Indicator startAnimating];
            tips = [NSString stringWithFormat:@"状态正常 识别中.."];

            if(self.handler){
                self.handler(self.finalImage);
            }
            self.recognizedSucceed = YES;
            dispatch_semaphore_signal(_sema);
            break;
        }
        default:
            break;
            
    }
    self.tipsLabel.text = tips;
#endif
}

//获取裁剪图片的 CGRect
- (CGRect)TransformTheRect{
    
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    
    CGFloat scale = cardScale * V_W(self.bankCardView);
    CGFloat scale2 = cardScale * V_H(self.bankCardView);
    
    //此算法版本对于身份证完整性要求较为严格，所以传给算法识别的图片会略大于裁剪框的大小
    CGFloat bankCardViewX = V_X(self.bankCardView) - scale;
    CGFloat bankCardViewY = V_Y(self.bankCardView) - scale2;
    CGFloat bankCardViewW = V_W(self.bankCardView) + scale*2;
    CGFloat bankCardViewH = V_H(self.bankCardView) + scale2*2;
    
    CGFloat bgImageViewX  = V_X(self.cutImageView.bgImageView);
    CGFloat bgImageViewY  = V_Y(self.cutImageView.bgImageView);
    CGFloat bgImageViewW  = V_W(self.cutImageView.bgImageView);
    CGFloat bgImageViewH  = V_H(self.cutImageView.bgImageView);
    
    if (self.imageOrientation == UIImageOrientationUp) {
        
        
        if (bankCardViewX< bgImageViewX) {
            
            x = 0;
            width = bankCardViewW - (bgImageViewX - bankCardViewX);
        }else{
            
            x = bankCardViewX-bgImageViewX;
            width = bankCardViewW;
        }
        
        if (bankCardViewY< bgImageViewY) {
            
            y = 0;
            height = bankCardViewH - (bgImageViewY - bankCardViewY);
        }else{
            
            y = bankCardViewY-bgImageViewY;
            height = bankCardViewH;
        }
        
        self.size = CGSizeMake(bgImageViewW, bgImageViewH);
    }else if (self.imageOrientation == UIImageOrientationRight){
        
        if (bankCardViewY<bgImageViewY) {
            
            x = 0;
            width = bankCardViewH - (bgImageViewY - bankCardViewY);
        }else{
            
            x = bankCardViewY - bgImageViewY;
            width = bankCardViewH;
        }
        
        CGFloat newCardViewX = bankCardViewX + bankCardViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        if (newCardViewX>newBgImageViewX) {
            y = 0;
            height = bankCardViewW - (newCardViewX - newBgImageViewX);
        }else{
            
            y = newBgImageViewX - newCardViewX;
            height = bankCardViewW;
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
    }else if (self.imageOrientation == UIImageOrientationLeft){
        
        if (bankCardViewX < bgImageViewX) {
            
            y = 0;
            height = bankCardViewW - (bgImageViewX - bankCardViewX);
        }else{
            
            y = bankCardViewX-bgImageViewX;
            height = bankCardViewW;
        }
        
        CGFloat newCardViewY = bankCardViewY + bankCardViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewY< newBgImageViewY) {
            
            x = newBgImageViewY - newCardViewY;
            width = bankCardViewH;
        }else{
            
            x = 0;
            width = bankCardViewH - (newCardViewY - newBgImageViewY);
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
    }else{
        
        CGFloat newCardViewX = bankCardViewX + bankCardViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        CGFloat newCardViewY = bankCardViewY + bankCardViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewX < newBgImageViewX) {
            
            x = newBgImageViewX - newCardViewX;
            width = bankCardViewW;
        }else{
            
            x = 0;
            width = bankCardViewW - (newCardViewX - newBgImageViewX);
        }
        
        if (newCardViewY < newBgImageViewY) {
            
            y = newBgImageViewY - newCardViewY;
            height = bankCardViewH;
            
        }else{
            
            y = 0;
            height = bankCardViewH - (newCardViewY - newBgImageViewY);
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



- (void)shapeLayerChangeLight{
    
    self.shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
}

- (void)shapeLayerChangeDark{
    
    self.shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
}


#pragma mark - dataSource && delegate

- (void)displayLinkNeedsDisplay:(AipDisplayLink *)displayLink{
    
    self.x ++;
    int x = 1000 / 60;
    int scale = timeNum/x;
    
    CGFloat num = self.x%scale;
    if (num == 0) {
        self.displaylinkisOn = YES;
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.displaylinkisOn) {
        
        @autoreleasepool {
            
            self.displaylinkisOn = NO;
            
            if (self.recognizedSucceed
#if !TARGET_IPHONE_SIMULATOR
                ||![self.idcard canWork]
#endif
                ) {
                return;
            }
            
            self.sema = dispatch_semaphore_create(0);
            UIImage *image = [[UIImage sapicamera_imageFromSampleBuffer:sampleBuffer] sapicamera_fixOrientation];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.cutImageView setBGImage:image fromPhotoLib:NO useGestureRecognizer:NO];

                [self pressCheckChoose:nil];
                
            });
            
            dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
            
        }
    }
    
}

//AipCutImageDelegate

- (void)AipCutImageBeginPaint{
    
}
- (void)AipCutImageScale{
    
    [self shapeLayerChangeLight];
}
- (void)AipCutImageMove{
    
    [self shapeLayerChangeLight];
}
- (void)AipCutImageEndPaint{
    
    [self shapeLayerChangeDark];
}

//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSAssert(image, @" ");
    if (image) {

        [self setupCutImageView:image fromPhotoLib:YES];
    
        //对于相册选取的照片暂时切换状态
        if (self.cardType == CardTypeLocalIdCardFont) {
            self.cardType = CardTypeIdCardFont;
            [self setupWithCardType];
        }else if (self.cardType == CardTypeLocalIdCardBack){
            self.cardType = CardTypeIdCardBack;
            [self setupWithCardType];
        }

        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.displaylink start];
    self.recognizedSucceed = NO;
}



#pragma mark - function

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    dispatch_semaphore_signal(_sema);
    self.recognizedSucceed = NO;
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

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
