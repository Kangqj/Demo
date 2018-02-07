//
//  AipCutImageView.h
//  BaiduOCR
//
//  Created by Yan,Xiangda on 2017/2/9.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "AipCutImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define     TAG_IMAGEVIEW       10
#define MAINHEIGHT  ([[UIScreen mainScreen] bounds].size.height > [[UIScreen mainScreen] bounds].size.width ? \
[[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#define MAINWIDTH   ([[UIScreen mainScreen] bounds].size.height > [[UIScreen mainScreen] bounds].size.width ? \
[[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

//捏合操作最大/最小系数
static CGFloat const pinchMaxscale = 10.0;
static CGFloat const pinchMinscale = 0.5;

@interface AipCutImageView (){
    /***********放大 拖动************/
    UIImage     *m_OriginalImg;  // 原始imgIO

    float _lastScale;
    float _lastTransX;
    float _lastTransY;
    float changescale;
    float curScale;     // 当前和原图缩放比例
    UIImage *m_CutImg;  // 剪切img

}
@property (strong, nonatomic) UIPanGestureRecognizer  *m_TwoPanGesture; // 双指事件
@property (strong, nonatomic) UIPinchGestureRecognizer*m_scaleGesture; // 缩放事件

@end

@implementation AipCutImageView

- (void)dealloc
{

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //截图的分辨率系数 开发者可自行配置.卡片识别可以比通用识别图片质量适当降低
        self.scale = 1.8;
    }
    return self;
}

- (void)awakeFromNib{
    
    [super awakeFromNib];
    //截图的分辨率系数 开发者可自行配置.卡片识别可以比通用识别图片质量适当降低
    self.scale = 1.8;
}

#pragma mark - AipImageViewDelegate

- (void)imageViewScaleWithGes:(UIPinchGestureRecognizer *)sender{
    
    [self scaleWithGes:sender];
}
- (void)imageViewMoveWithGes:(UIPanGestureRecognizer *)sender{
    
    [self moveWithGes:sender];
}

#pragma mark - 手势相关

- (void)viewScaleWithGes:(UIPinchGestureRecognizer *)sender{
    
    [self scaleWithGes:sender];
}

- (void)viewMoveWithGes:(UIPanGestureRecognizer *)sender{
    
    [self moveWithGes:sender];
}

- (void)scaleWithGes:(UIPinchGestureRecognizer *)sender {
    if([sender state] == UIGestureRecognizerStateBegan) {
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageBeginPaint)]) {
            [self.imgDelegate AipCutImageBeginPaint];
        }
        _lastScale = 1.0;
        changescale = curScale;
        [self correctAnchorPointBaseOnGestureRecognizer:sender withMskView:self.bgImageView];
        return;
    }else if ([sender state] == UIGestureRecognizerStateChanged) {
        
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageScale)]) {
            [self.imgDelegate AipCutImageScale];
        }
        if (self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width < MAINWIDTH/2 || self.bgImageView.frame.origin.x > MAINWIDTH-100 || self.bgImageView.frame.origin.y+self.bgImageView.frame.size.height < MAINHEIGHT/2 || self.bgImageView.frame.origin.y>MAINHEIGHT-200) {
            return;
        }
        CGFloat ifscale = [sender scale]*curScale;
        if (ifscale > pinchMinscale && ifscale < pinchMaxscale) {
            CGFloat scale = [sender scale]/_lastScale;
            CGAffineTransform currentTransform = self.bgImageView.transform;
            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
            [self.bgImageView setTransform:newTransform];
            _lastScale = [sender scale];
            changescale = ifscale;
        }
        
    }else if ([sender state] == UIGestureRecognizerStateEnded) {
        if (self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width < MAINWIDTH/2 || self.bgImageView.frame.origin.x > MAINWIDTH-100 || self.bgImageView.frame.origin.y+self.bgImageView.frame.size.height < MAINHEIGHT/2 || self.bgImageView.frame.origin.y>MAINHEIGHT-200) {
            return;
        }

        CGFloat maxscale = curScale*[sender scale];
        if (maxscale > pinchMinscale && maxscale < pinchMaxscale) {
            curScale = curScale*[sender scale];
            CGFloat scale = [sender scale]/_lastScale;
            CGAffineTransform currentTransform = self.bgImageView.transform;
            CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
            [self.bgImageView setTransform:newTransform];
            _lastScale = [sender scale];
            changescale = curScale;
        }else {
            curScale = changescale;
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {
        
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageEndPaint)]) {
            [self.imgDelegate AipCutImageEndPaint];
        }
        [self setDefaultAnchorPointforView:self.bgImageView];
    }

}

- (void)moveWithGes:(UIPanGestureRecognizer *)sender {
    CGPoint translatedPoint = [sender translationInView:self];
    if (self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width+translatedPoint.x < MAINWIDTH/2 || self.bgImageView.frame.origin.x+translatedPoint.x > MAINWIDTH-100 || self.bgImageView.frame.origin.y+self.bgImageView.frame.size.height+translatedPoint.y < MAINHEIGHT/2 || self.bgImageView.frame.origin.y+translatedPoint.y>MAINHEIGHT-200) {
        return;
    }
    if([sender state] == UIGestureRecognizerStateBegan) {
        
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageMove)]) {
            [self.imgDelegate AipCutImageMove];
        }
        _lastTransX = 0.0;
        _lastTransY = 0.0;

    }else if ([sender state] == UIGestureRecognizerStateChanged){
        
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageScale)]) {
            [self.imgDelegate AipCutImageScale];
        }
    }
    
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled) {
        
        if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(AipCutImageEndPaint)]) {
            [self.imgDelegate AipCutImageEndPaint];
        }
    }
    CGAffineTransform trans = CGAffineTransformMakeTranslation(translatedPoint.x - _lastTransX, translatedPoint.y - _lastTransY);
    CGAffineTransform newTransform = CGAffineTransformConcat(self.bgImageView.transform, trans);
    _lastTransX = translatedPoint.x;
    _lastTransY = translatedPoint.y;
    
    self.bgImageView.transform = newTransform;
}

#pragma mark 缩放中心点处理

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

- (void)setDefaultAnchorPointforView:(UIView *)view
{
    [self setAnchorPoint:CGPointMake(0.5f, 0.5f) forView:view];
}

- (void)correctAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gr withMskView:(UIView *)maskView
{
    CGPoint onoPoint = [gr locationOfTouch:0 inView:gr.view];
    CGPoint twoPoint = [gr locationOfTouch:1 inView:gr.view];
    
    CGPoint anchorPoint;
    anchorPoint.x = (onoPoint.x + twoPoint.x) / 2 / gr.view.bounds.size.width;
    anchorPoint.y = (onoPoint.y + twoPoint.y) / 2 / gr.view.bounds.size.height;
    
//    [self setAnchorPoint:anchorPoint forView:gr.view];
    [self setAnchorPoint:anchorPoint forView:maskView];
}

- (void)correctAnchorPointForView:(UIView *)view
{
    CGPoint anchorPoint = CGPointZero;
    CGPoint superviewCenter = view.superview.center;
    //   superviewCenter是view的superview 的 center 在view.superview.superview中的坐标。
    CGPoint viewPoint = [view convertPoint:superviewCenter fromView:view.superview.superview];
    //   转换坐标，得到superviewCenter 在 view中的坐标
    anchorPoint.x = (viewPoint.x) / view.bounds.size.width;
    anchorPoint.y = (viewPoint.y) / view.bounds.size.height;
    
    [self setAnchorPoint:anchorPoint forView:view];
}


#pragma mark - 从页面上截取frame大小的图片


- (UIImage *)cutImageFromView:(UIImageView *)theView withSize:(CGSize)ori atFrame:(CGRect)rect
{
    
    CGFloat scale = self.scale;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ori.width*scale, ori.height*scale)];
    CALayer *ilayer = imgView.layer;
    if (self.isImageFromLib)
    {
        ilayer.contentsGravity = @"resizeAspect";
    }
    else
    {
        ilayer.contentsGravity = @"resizeAspectFill";
    }
    imgView.image = theView.image;
    
    CGRect rectClip = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    UIGraphicsBeginImageContext(CGSizeMake(ori.width*scale, ori.height*scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(CGRectMake(rectClip.origin.x - 1.0f , rectClip.origin.y - 1.0f, rectClip.size.width + 2.0f, rectClip.size.height + 2.0f));
    [ilayer renderInContext:context];
    UIImage * theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([theImage CGImage], rectClip);
    
    UIImage *result;
    result = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);

    return result;
}

/**
 *  cutImageFromView2:
 *      从 imageView 中截取图片
 *      截取大小相对于 imageView 中的 image 大小
 */
- (UIImage *)cutImageFromView2:(UIView *)theView atFrame:(CGRect)rect {
    

    UIImageView *imageView = (UIImageView *)theView;
    
    UIImage *originImage = imageView.image;
    CGSize viewSize = theView.frame.size;
    CGSize originImageSize = originImage.size;
    
    
    UIViewContentMode contentMode = imageView.contentMode;
//    NSLog(@"%d", contentMode);
    
    /**
     *  view 与 image 宽、高的相对比例
     *  选择大的相对比例
     */
    CGFloat widthScale = viewSize.width / originImageSize.width;
    CGFloat heightScale = viewSize.height / originImageSize.height;
    CGFloat minScale = MIN(widthScale, heightScale);
    CGFloat maxScale = MAX(widthScale, heightScale);
    /**
     *  是否是高度适配
     */
    BOOL isHeightFit = NO;
    if (contentMode == UIViewContentModeScaleAspectFill) {
        if (minScale == widthScale) {
            isHeightFit = YES;
        }
    } else if (contentMode == UIViewContentModeScaleAspectFit) {
        if (maxScale == widthScale) {
            isHeightFit = YES;
        }
    }
    
    CGRect realCutRect = rect;
    /**
     *  如果不是高度适配，则需要调整 y 位标
     */
    if (!isHeightFit) {
        if (contentMode == UIViewContentModeScaleAspectFill) {
            CGFloat yOffset = (originImageSize.height * maxScale - viewSize.height) / 2.0;
            realCutRect.origin.y += yOffset;
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
            CGFloat yOffset = (originImageSize.height * minScale - viewSize.height) / 2.0;
            realCutRect.origin.y += yOffset;
        }
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill) {
            CGFloat xOffset = (originImageSize.width * maxScale - viewSize.width) / 2.0;
            realCutRect.origin.x += xOffset;
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
            CGFloat xOffset = (originImageSize.width * minScale - viewSize.width) / 2.0;
            realCutRect.origin.x += xOffset;
        }
    }
    /**
     *  把需要剪切区域按比例放大
     */
    if (contentMode == UIViewContentModeScaleAspectFill) {
        realCutRect.origin.x *= 1.0 / maxScale;
        realCutRect.origin.y *= 1.0 / maxScale;
        realCutRect.size.width *= 1.0 / maxScale;
        realCutRect.size.height *= 1.0 / maxScale;
     } else if (contentMode == UIViewContentModeScaleAspectFit) {
         realCutRect.origin.x *= 1.0 / minScale;
         realCutRect.origin.y *= 1.0 / minScale;
         realCutRect.size.width *= 1.0 / minScale;
         realCutRect.size.height *= 1.0 / minScale;
     }

    /**
     *  从原图中截取剪切区域图片
     */
    UIImage *image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([originImage CGImage], realCutRect)];

    return image;
}

/**
 *  cutMaskImageFromView:
 *      从 imageView 中截取图片
 *      截取大小相对于 imageView 中的 image 大小
 */
- (UIImage *)cutMaskImageFromView:(UIView *)theView atFrame:(CGRect)rect {
    UIImageView *imageView = (UIImageView *)theView;
    UIImage *originImage = imageView.image;
    
    CGRect realCutRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    /**
     *  从原图中截取剪切区域图片
     */
    UIImage *image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([originImage CGImage], realCutRect)];
    
    return image;
}

#pragma mark - 与controller交互
// 得到原图
- (void)setBGImage:(UIImage *)aImage fromPhotoLib:(BOOL)isFromLib useGestureRecognizer:(BOOL)isUse{
    
    if (self.bgImageView) {
        [self.bgImageView removeFromSuperview];
        self.bgImageView = nil;
    }
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.bgImageView setBackgroundColor:[UIColor blackColor]];
    self.bgImageView.userInteractionEnabled = YES;
    self.bgImageView.tag = TAG_IMAGEVIEW;
    CALayer *layer = self.bgImageView.layer;
    layer.contentsGravity = @"resizeAspectFill";
    [self addSubview:self.bgImageView];
    
    if (isFromLib) {
        layer.contentsGravity = @"resizeAspect";
    } else {
        layer.contentsGravity = @"resizeAspectFill";
    }
    
    self.isImageFromLib = isFromLib;
    self.bgImageView.image = aImage;
    /******放大 拖动**********/
    _lastScale = 1.0;
    _lastTransX = 0.0;
    _lastTransY = 0.0;
    m_OriginalImg = aImage;
    curScale = 1.0;
    
    if (isUse) {
        
        self.m_scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewScaleWithGes:)];
        self.m_TwoPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewMoveWithGes:)];
        
        [self addGestureRecognizer:_m_TwoPanGesture];
        [self addGestureRecognizer:_m_scaleGesture];
    }
}

@end
