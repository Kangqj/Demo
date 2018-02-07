//
//  AipImageView.m
//  BaiduOCR
//
//  Created by Yan,Xiangda on 2017/2/9.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "AipImageView.h"

#define WIDTH(_view) CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)
#define MID_LINE_INTERACT_WIDTH 44
#define MID_LINE_INTERACT_HEIGHT 44

typedef NS_ENUM(NSInteger, IOCropAreaCornerPosition) {
    IOCropAreaCornerPositionTopLeft,
    IOCropAreaCornerPositionTopRight,
    IOCropAreaCornerPositionBottomLeft,
    IOCropAreaCornerPositionBottomRight
};
typedef NS_ENUM(NSInteger, IOMidLineType) {
    
    IOMidLineTypeTop,
    IOMidLineTypeBottom,
    IOMidLineTypeLeft,
    IOMidLineTypeRight
    
};
@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
- (UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}
@end
@interface CornerView: UIView

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) IOCropAreaCornerPosition cornerPosition;
@property (assign, nonatomic) CornerView *relativeViewX;
@property (assign, nonatomic) CornerView *relativeViewY;
@property (strong, nonatomic) CAShapeLayer *cornerShapeLayer;

- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height;
@end
@implementation CornerView
- (instancetype)initWithFrame:(CGRect)frame lineColor: (UIColor *)lineColor lineWidth: (CGFloat)lineWidth {
    
    self = [super initWithFrame: frame];
    if(self) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}
- (void)setCornerPosition:(IOCropAreaCornerPosition)cornerPosition {
    
    _cornerPosition = cornerPosition;
    [self drawCornerLines];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawCornerLines];
    
}
- (void)drawCornerLines {
    
    if(_cornerShapeLayer && _cornerShapeLayer.superlayer) {
        [_cornerShapeLayer removeFromSuperlayer];
    }
    _cornerShapeLayer = [CAShapeLayer layer];
    _cornerShapeLayer.lineWidth = _lineWidth;
    _cornerShapeLayer.strokeColor = _lineColor.CGColor;
    _cornerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    CGFloat paddingX = _lineWidth / 2.0f;
    CGFloat paddingY = _lineWidth / 2.0f;
    switch (_cornerPosition) {
        case IOCropAreaCornerPositionTopLeft: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self), paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self))];
            break;
        }
        case IOCropAreaCornerPositionTopRight: {
            [cornerPath moveToPoint:CGPointMake(0, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self))];
            break;
        }
        case IOCropAreaCornerPositionBottomLeft: {
            [cornerPath moveToPoint:CGPointMake(paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self), HEIGHT(self) - paddingY)];
            break;
        }
        case IOCropAreaCornerPositionBottomRight: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self) - paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(0, HEIGHT(self) - paddingY)];
            break;
        }
        default:
            break;
    }
    _cornerShapeLayer.path = cornerPath.CGPath;
    [self.layer addSublayer: _cornerShapeLayer];
    
}
- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height {
    
    switch (_cornerPosition) {
        case IOCropAreaCornerPositionTopLeft: {
            self.frame = CGRectMake(MINX(self), MINY(self), width, height);
            break;
        }
        case IOCropAreaCornerPositionTopRight: {
            self.frame = CGRectMake(MAXX(self) - width, MINY(self), width, height);
            break;
        }
        case IOCropAreaCornerPositionBottomLeft: {
            self.frame = CGRectMake(MINX(self), MAXY(self) - height, width, height);
            break;
        }
        case IOCropAreaCornerPositionBottomRight: {
            self.frame = CGRectMake(MAXX(self) - width, MAXY(self) - height, width, height);
            break;
        }
        default:
            break;
    }
    [self drawCornerLines];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _cornerShapeLayer.strokeColor = lineColor.CGColor;
    
}
@end

@interface MidLineView : UIView
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineHeight;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) IOMidLineType type;
@end
@implementation MidLineView
- (instancetype)initWithLineWidth: (CGFloat)lineWidth lineHeight: (CGFloat)lineHeight lineColor: (UIColor *)lineColor {
    
    self = [super initWithFrame: CGRectMake(0, 0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT)];
    if(self) {
        self.lineWidth = lineWidth;
        self.lineHeight = lineHeight;
        self.lineColor = lineColor;
    }
    return self;
    
}
- (void)setType:(IOMidLineType)type {
    
    _type = type;
    [self drawMidLine];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawMidLine];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _lineLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setLineHeight:(CGFloat)lineHeight {
    
    _lineHeight = lineHeight;
    _lineLayer.lineWidth = lineHeight;
    
}
- (void)drawMidLine {
    
    if(_lineLayer && _lineLayer.superlayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = _lineColor.CGColor;
    _lineLayer.lineWidth = _lineHeight;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *midLinePath = [UIBezierPath bezierPath];
    switch (_type) {
        case IOMidLineTypeTop:
        case IOMidLineTypeBottom: {
            [midLinePath moveToPoint:CGPointMake((WIDTH(self) - _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake((WIDTH(self) + _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            break;
        }
        case IOMidLineTypeRight:
        case IOMidLineTypeLeft: {
            [midLinePath moveToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) - _lineWidth) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) + _lineWidth) / 2.0)];
            break;
        }
        default:
            break;
    }
    _lineLayer.path = midLinePath.CGPath;
    [self.layer addSublayer: _lineLayer];
    
}
@end

@interface CropAreaView ()

@property (strong, nonatomic) CAShapeLayer *crossLineLayer;
@property (assign, nonatomic) CGFloat crossLineWidth;
@property (strong, nonatomic) UIColor *crossLineColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (assign, nonatomic) BOOL showCrossLines;
@end

@implementation CropAreaView

- (instancetype)init {
    
    self = [super init];
    if(self) {
        [self createBorderLayer];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    if(_showCrossLines) {
        [self showCrossLineLayer];
    }
    [self resetBorderLayerPath];
    
}
- (void)showCrossLineLayer {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0 * 2.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0 * 2.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0)];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0 * 2.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0 * 2.0)];
    if(!_crossLineLayer) {
        _crossLineLayer = [CAShapeLayer layer];
        [self.layer addSublayer: _crossLineLayer];
    }
    _crossLineLayer.lineWidth = _crossLineWidth;
    _crossLineLayer.strokeColor = _crossLineColor.CGColor;
    _crossLineLayer.path = path.CGPath;
    
}
- (void)setCrossLineWidth:(CGFloat)crossLineWidth {
    
    _crossLineWidth = crossLineWidth;
    _crossLineLayer.lineWidth = crossLineWidth;
    
}
- (void)setCrossLineColor:(UIColor *)crossLineColor {
    
    _crossLineColor = crossLineColor;
    _crossLineLayer.strokeColor = crossLineColor.CGColor;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    if(_showCrossLines && !showCrossLines) {
        [_crossLineLayer removeFromSuperlayer];
        _crossLineLayer = nil;
    }
    else if(!_showCrossLines && showCrossLines) {
        [self showCrossLineLayer];
    }
    _showCrossLines = showCrossLines;
    
}
- (void)createBorderLayer {
    
    if(_borderLayer && _borderLayer.superlayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer: _borderLayer];
    
}
- (void)resetBorderLayerPath {
    
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRect: CGRectMake(_borderWidth / 2.0f, _borderWidth / 2.0f, WIDTH(self) - _borderWidth, HEIGHT(self) - _borderWidth)];
    _borderLayer.lineWidth = _borderWidth;
    _borderLayer.fillColor = nil;
    _borderLayer.path = layerPath.CGPath;
    
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
    [self resetBorderLayerPath];
    
}
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
    
}
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
    
}
@end
@interface AipImageView()

@property (strong, nonatomic) UIView *cropMaskView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CornerView *topLeftCorner;
@property (strong, nonatomic) CornerView *topRightCorner;
@property (strong, nonatomic) CornerView *bottomLeftCorner;
@property (strong, nonatomic) CornerView *bottomRightCorner;
@property (strong, nonatomic) UIPanGestureRecognizer *topLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *topRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *cropAreaPan;
@property (strong, nonatomic) UIPanGestureRecognizer  *m_TwoPanGesture; // 双指事件
@property (strong, nonatomic) UIPinchGestureRecognizer*m_scaleGesture; // 缩放事件
@property (assign, nonatomic) CGSize pinchOriSize;
@property (assign, nonatomic) CGPoint cropAreaOriCenter;
@property (assign, nonatomic) CGRect cropAreaOriFrame;
@property (strong, nonatomic) MidLineView *topMidLine;
@property (strong, nonatomic) MidLineView *leftMidLine;
@property (strong, nonatomic) MidLineView *bottomMidLine;
@property (strong, nonatomic) MidLineView *rightMidLine;
@property (strong, nonatomic) UIPanGestureRecognizer *topMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *leftMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *rightMidPan;
@property (assign, nonatomic) CGFloat paddingLeftRight;
@property (assign, nonatomic) CGFloat paddingTopBottom;
@property (assign, nonatomic) CGFloat imageAspectRatio;
@end

@implementation AipImageView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (void)commonInit {
    
    [self setUp];
    [self createCorners];
    [self resetCropAreaOnCornersFrameChanged];
    [self bindPanGestures];
    
}
- (void)dealloc {
    
    [_cropAreaView removeObserver: self forKeyPath: @"frame"];
    [_cropAreaView removeObserver: self forKeyPath: @"center"];
    
}
- (void)setUp {
    
    _imageAspectRatio = 0;
    
    _cropMaskView = [[UIView alloc]initWithFrame: self.bounds];
    _cropMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: _cropMaskView];
    
    UIColor *defaultColor = [UIColor colorWithWhite: 1 alpha: 0.8];
    _cropAreaBorderLineColor = defaultColor;
    _cropAreaCornerLineColor = [UIColor whiteColor];
    _cropAreaBorderLineWidth = 4;
    _cropAreaCornerLineWidth = 6;
    _cropAreaCornerWidth = 30;
    _cropAreaCornerHeight = 30;
    _cropAspectRatio = 0;
    _minSpace = 30;
    _cropAreaCrossLineWidth = 4;
    _cropAreaCrossLineColor = defaultColor;
    _cropAreaMidLineWidth = 40;
    _cropAreaMidLineHeight = 6;
    _cropAreaMidLineColor = defaultColor;
    
    _cropAreaView = [[CropAreaView alloc] init];
    _cropAreaView.borderWidth = _cropAreaBorderLineWidth;
    _cropAreaView.borderColor = _cropAreaBorderLineColor;
    _cropAreaView.crossLineColor = _cropAreaCrossLineColor;
    _cropAreaView.crossLineWidth = _cropAreaCrossLineWidth;
    _cropAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: _cropAreaView];
    
    [_cropAreaView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_cropAreaView addObserver: self
                    forKeyPath: @"center"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    
    
    
}
#pragma mark - PanGesture Bind
- (void)bindPanGestures {
    
    _topLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _topRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _cropAreaPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCropAreaPan:)];
    
    _m_scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleView:)];
    _m_TwoPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
//    [_m_TwoPanGesture setMinimumNumberOfTouches:2];
//    [_m_TwoPanGesture setMaximumNumberOfTouches:2];
    
    [_topLeftCorner addGestureRecognizer: _topLeftPan];
    [_topRightCorner addGestureRecognizer: _topRightPan];
    [_bottomLeftCorner addGestureRecognizer: _bottomLeftPan];
    [_bottomRightCorner addGestureRecognizer: _bottomRightPan];
    [_cropAreaView addGestureRecognizer: _cropAreaPan];
    
    [self addGestureRecognizer:_m_TwoPanGesture];
    [self addGestureRecognizer:_m_scaleGesture];
    
    
}
#pragma mark - PinchGesture CallBack

- (void)scaleView:(UIPinchGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(imageViewScaleWithGes:)]) {
        
        [self.delegate imageViewScaleWithGes:sender];
    }
}


#pragma mark - PanGesture CallBack

- (void)moveView:(UIPanGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(imageViewMoveWithGes:)]) {
        [self.delegate imageViewMoveWithGes:sender];
    }
}

- (void)handleCropAreaPan: (UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriCenter = _cropAreaView.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: self];
            CGPoint willCenter = CGPointMake(_cropAreaOriCenter.x + translation.x, _cropAreaOriCenter.y + translation.y);
            CGFloat cornerMargin = _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
            CGFloat centerMinX = WIDTH(_cropAreaView) / 2.0f + cornerMargin;
            CGFloat centerMaxX = WIDTH(self) - WIDTH(_cropAreaView) / 2.0f - cornerMargin;
            CGFloat centerMinY = HEIGHT(_cropAreaView) / 2.0f + cornerMargin;
            CGFloat centerMaxY = HEIGHT(self) - HEIGHT(_cropAreaView) / 2.0f - cornerMargin;
            _cropAreaView.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
            [self resetCornersOnCropAreaFrameChanged];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleMidPan: (UIPanGestureRecognizer *)panGesture {
    //ytodo
    _cropAspectRatio = 0;
    MidLineView *midLineView = (MidLineView *)panGesture.view;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriFrame = _cropAreaView.frame;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _cropAreaView];
            switch (midLineView.type) {
                case IOMidLineTypeTop: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = CGRectGetMaxY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) - translation.y), maxHeight);
                    CGFloat deltaY = willHeight - CGRectGetHeight(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame) - deltaY, CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case IOMidLineTypeBottom: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = HEIGHT(self) - CGRectGetMinY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) + translation.y), maxHeight);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    break;
                }
                case IOMidLineTypeLeft: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = CGRectGetMaxX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) - translation.x), maxWidth);
                    CGFloat deltaX = willWidth - CGRectGetWidth(_cropAreaOriFrame);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame) - deltaX, CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                case IOMidLineTypeRight: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = WIDTH(self) - CGRectGetMinX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) + translation.x), maxWidth);
                    _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    break;
                }
                default:
                    break;
            }
            [self resetCornersOnCropAreaFrameChanged];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleCornerPan: (UIPanGestureRecognizer *)panGesture {
    //ytodo
    _cropAspectRatio = 0;
    CornerView *panView = (CornerView *)panGesture.view;
    CornerView *relativeViewX = panView.relativeViewX;
    CornerView *relativeViewY = panView.relativeViewY;
    CGPoint locationInImageView = [panGesture locationInView: self];
    NSInteger xFactor = MINX(relativeViewY) > MINX(panView) ? -1 : 1;
    NSInteger yFactor = MINY(relativeViewX) > MINY(panView) ? -1 : 1;
    
    CGFloat spaceX = MIN(MAX((locationInImageView.x - relativeViewY.center.x) * xFactor + _cropAreaCornerWidth - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2, _minSpace + _cropAreaCornerWidth * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2), xFactor < 0 ? relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2 : WIDTH(self) - relativeViewY.center.x + _cropAreaCornerWidth / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
    
    CGFloat spaceY = MIN(MAX((locationInImageView.y - relativeViewX.center.y) * yFactor + _cropAreaCornerHeight - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2, _minSpace + _cropAreaCornerHeight * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2), yFactor < 0 ? relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2 : HEIGHT(self) - relativeViewX.center.y + _cropAreaCornerHeight / 2.0 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
    
    if(_cropAspectRatio > 0) {
        if(_cropAspectRatio >= 1) {
            spaceY = MAX(spaceX / _cropAspectRatio, _minSpace + _cropAreaCornerHeight * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
            spaceX = spaceY * _cropAspectRatio;
        }
        else {
            spaceX = MAX(spaceY * _cropAspectRatio, _minSpace + _cropAreaCornerWidth * 2 - _cropAreaCornerLineWidth * 2 + _cropAreaBorderLineWidth * 2);
            spaceY = spaceX / _cropAspectRatio;
        }
    }
    
    CGFloat centerX = (spaceX - _cropAreaCornerWidth + _cropAreaCornerLineWidth * 2 -  _cropAreaBorderLineWidth * 2) * xFactor + relativeViewY.center.x;
    CGFloat centerY = (spaceY - _cropAreaCornerHeight + _cropAreaCornerLineWidth * 2 - _cropAreaBorderLineWidth * 2) * yFactor + relativeViewX.center.y;
    panView.center = CGPointMake(MIN(MAX(_cropAreaCornerWidth / 2.0, centerX), WIDTH(self) - _cropAreaCornerWidth / 2.0), MIN(MAX(_cropAreaCornerHeight / 2.0, centerY), HEIGHT(self) - _cropAreaCornerHeight / 2.0));
    relativeViewX.frame = CGRectMake(MINX(panView), MINY(relativeViewX), WIDTH(relativeViewX), HEIGHT(relativeViewX));
    relativeViewY.frame = CGRectMake(MINX(relativeViewY), MINY(panView), WIDTH(relativeViewY), HEIGHT(relativeViewY));
    [self resetCropAreaOnCornersFrameChanged];
    [self resetCropTransparentArea];
    
}
#pragma mark - Position/Resize Corners&CropArea
- (void)resetCornersOnCropAreaFrameChanged {
    
    _topLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _topRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    
}

- (void)resetCropAreaOnCornersFrameChanged {
    
    _cropAreaView.frame = CGRectMake(MINX(_topLeftCorner) + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MINY(_topLeftCorner) + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MAXX(_topRightCorner) - MINX(_topLeftCorner) - 2 * _cropAreaCornerLineWidth + 2 * _cropAreaBorderLineWidth, MAXY(_bottomLeftCorner) - MINY(_topLeftCorner) - 2 * _cropAreaCornerLineWidth + 2 * _cropAreaBorderLineWidth);
    
}
- (void)resetCropTransparentArea {

    UIBezierPath *path = [UIBezierPath bezierPathWithRect: self.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: _cropAreaView.frame] bezierPathByReversingPath];
    [path appendPath: clearPath];
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;
    
}
- (void)resetCornersOnSizeChanged {
    
    [_topLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_topRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    
}
- (void)createCorners {
    
    _topLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor:_cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _topLeftCorner.cornerPosition = IOCropAreaCornerPositionTopLeft;
    
    _topRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(self) -  _cropAreaCornerWidth, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topRightCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _topRightCorner.cornerPosition = IOCropAreaCornerPositionTopRight;
    
    _bottomLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, HEIGHT(self) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _bottomLeftCorner.cornerPosition = IOCropAreaCornerPositionBottomLeft;
    
    _bottomRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(self) - _cropAreaCornerWidth, HEIGHT(self) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomRightCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    _bottomRightCorner.cornerPosition = IOCropAreaCornerPositionBottomRight;
    
    _topLeftCorner.relativeViewX = _bottomLeftCorner;
    _topLeftCorner.relativeViewY = _topRightCorner;
    
    _topRightCorner.relativeViewX = _bottomRightCorner;
    _topRightCorner.relativeViewY = _topLeftCorner;
    
    _bottomLeftCorner.relativeViewX = _topLeftCorner;
    _bottomLeftCorner.relativeViewY = _bottomRightCorner;
    
    _bottomRightCorner.relativeViewX = _topRightCorner;
    _bottomRightCorner.relativeViewY = _bottomLeftCorner;
    
    [self addSubview: _topLeftCorner];
    [self addSubview: _topRightCorner];
    [self addSubview: _bottomLeftCorner];
    [self addSubview: _bottomRightCorner];
    
}
- (void)createMidLines {
    
    _topMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _topMidLine.type = IOMidLineTypeTop;
    
    _bottomMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _bottomMidLine.type = IOMidLineTypeBottom;
    
    _leftMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _leftMidLine.type = IOMidLineTypeLeft;
    
    _rightMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _rightMidLine.type = IOMidLineTypeRight;
    
    _topMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_topMidLine addGestureRecognizer: _topMidPan];
    
    _bottomMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_bottomMidLine addGestureRecognizer: _bottomMidPan];
    
    _leftMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_leftMidLine addGestureRecognizer: _leftMidPan];
    
    _rightMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_rightMidLine addGestureRecognizer: _rightMidPan];
    
    [_cropAreaView addSubview: _topMidLine];
    [_cropAreaView addSubview: _bottomMidLine];
    [_cropAreaView addSubview: _leftMidLine];
    [_cropAreaView addSubview: _rightMidLine];
    
}
- (void)removeMidLines {
    
    [_topMidLine removeFromSuperview];
    [_bottomMidLine removeFromSuperview];
    [_leftMidLine removeFromSuperview];
    [_rightMidLine removeFromSuperview];
    
    _topMidLine = nil;
    _bottomMidLine = nil;
    _leftMidLine = nil;
    _rightMidLine = nil;
    
}
- (void)resetMidLines {
    
    CGFloat lineMargin = _cropAreaMidLineHeight / 2.0 - _cropAreaBorderLineWidth;
    _topMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, - MID_LINE_INTERACT_HEIGHT / 2.0 - lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _bottomMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT / 2.0 + lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _leftMidLine.frame = CGRectMake(- MID_LINE_INTERACT_WIDTH / 2.0 - lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _rightMidLine.frame = CGRectMake(WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH / 2.0 + lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    
}

#pragma mark - Setter & Getters
- (void)setMaskColor:(UIColor *)maskColor {
    
    _maskColor = maskColor;
    _cropMaskView.backgroundColor = maskColor;
    
}
- (void)setToCropImage:(UIImage *)toCropImage {
    
    _toCropImage = toCropImage;
    _imageAspectRatio = toCropImage.size.width / toCropImage.size.height;
    
}

- (void)setCropAreaCrossLineWidth:(CGFloat)cropAreaCrossLineWidth {
    
    _cropAreaCrossLineWidth = cropAreaCrossLineWidth;
    _cropAreaView.crossLineWidth = cropAreaCrossLineWidth;
    
}
- (void)setCropAreaCrossLineColor:(UIColor *)cropAreaCrossLineColor {
    
    _cropAreaCrossLineColor = cropAreaCrossLineColor;
    _cropAreaView.crossLineColor = cropAreaCrossLineColor;
    
}
- (void)setCropAreaMidLineWidth:(CGFloat)cropAreaMidLineWidth {
    
    _cropAreaMidLineWidth = cropAreaMidLineWidth;
    _topMidLine.lineWidth = cropAreaMidLineWidth;
    _bottomMidLine.lineWidth = cropAreaMidLineWidth;
    _leftMidLine.lineWidth = cropAreaMidLineWidth;
    _rightMidLine.lineWidth = cropAreaMidLineWidth;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineHeight:(CGFloat)cropAreaMidLineHeight {
    
    _cropAreaMidLineHeight = cropAreaMidLineHeight;
    _topMidLine.lineHeight = cropAreaMidLineHeight;
    _bottomMidLine.lineHeight = cropAreaMidLineHeight;
    _leftMidLine.lineHeight = cropAreaMidLineHeight;
    _rightMidLine.lineHeight = cropAreaMidLineHeight;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineColor:(UIColor *)cropAreaMidLineColor {
    
    _cropAreaMidLineColor = cropAreaMidLineColor;
    _topMidLine.lineColor = cropAreaMidLineColor;
    _bottomMidLine.lineColor = cropAreaMidLineColor;
    _leftMidLine.lineColor = cropAreaMidLineColor;
    _rightMidLine.lineColor = cropAreaMidLineColor;
    
}
- (void)setCropAreaBorderLineWidth:(CGFloat)cropAreaBorderLineWidth {
    
    _cropAreaBorderLineWidth = cropAreaBorderLineWidth;
    _cropAreaView.borderWidth = cropAreaBorderLineWidth;
    [self resetCropAreaOnCornersFrameChanged];
    
}
- (void)setCropAreaBorderLineColor:(UIColor *)cropAreaBorderLineColor {
    
    _cropAreaBorderLineColor = cropAreaBorderLineColor;
    _cropAreaView.borderColor = cropAreaBorderLineColor;
    
}
- (void)setCropAreaCornerLineColor:(UIColor *)cropAreaCornerLineColor {
    
    _cropAreaCrossLineColor = cropAreaCornerLineColor;
    _topLeftCorner.lineColor = cropAreaCornerLineColor;
    _topRightCorner.lineColor = cropAreaCornerLineColor;
    _bottomLeftCorner.lineColor = cropAreaCornerLineColor;
    _bottomRightCorner.lineColor = cropAreaCornerLineColor;
    
}
- (void)setCropAreaCornerLineWidth:(CGFloat)cropAreaCornerLineWidth {
    
    _cropAreaCornerLineWidth = cropAreaCornerLineWidth;
    _topLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _topRightCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomRightCorner.lineWidth = cropAreaCornerLineWidth;
    
}
- (void)setCropAreaCornerWidth:(CGFloat)cropAreaCornerWidth {
    
    _cropAreaCornerWidth = cropAreaCornerWidth;
    [self resetCornersOnSizeChanged];
    [self resetCropAreaOnCornersFrameChanged];
    
}
- (void)setCropAreaCornerHeight:(CGFloat)cropAreaCornerHeight {
    
    _cropAreaCornerHeight = cropAreaCornerHeight;
    [self resetCornersOnSizeChanged];
    [self resetCropAreaOnCornersFrameChanged];
    
}
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio {
    
    if(_cropAspectRatio == cropAspectRatio) return;
    _cropAspectRatio = MAX(cropAspectRatio, 0);
    CGFloat cornerMargin = _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
    CGFloat selfAspectRatio = WIDTH(self) / HEIGHT(self);
    CGFloat width, height;
    if(_cropAspectRatio == 0) {
        width = WIDTH(self) - 2 * cornerMargin;
        height = HEIGHT(self) - 2 * cornerMargin;
        if(_showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
        _cropAreaView.frame = CGRectMake(0, 0, width, height);
    }else {
        [self removeMidLines];
        if(selfAspectRatio > _cropAspectRatio) {
            height = HEIGHT(self) - 2 * cornerMargin;
            width = height * _cropAspectRatio;
        }
        else {
            width = WIDTH(self) - 2 * cornerMargin;
            height = width / _cropAspectRatio;
        }
        _cropAreaView.frame = CGRectMake((WIDTH(self) - width) / 2.0 + 22, 50, width - 44, height - 44 / cropAspectRatio);
    }
    [self resetCornersOnCropAreaFrameChanged];
    [self resetCropTransparentArea];
    
}
- (void)setShowMidLines:(BOOL)showMidLines {
    
    if(_cropAspectRatio == 0) {
        if(!_showMidLines && showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
        else if(_showMidLines && !showMidLines) {
            [self removeMidLines];
        }
    }
    _showMidLines = showMidLines;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    _showCrossLines = showCrossLines;
    _cropAreaView.showCrossLines = _showCrossLines;
    
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    
}
- (void)setCenter:(CGPoint)center {
    
    [super setCenter: center];
    
}

- (UIView *)rectView{
    
    if (!_rectView) {
        _rectView = [[UIView alloc]init];
    }
    _rectView.frame = self.cropAreaView.frame;
    return _rectView;
}

#pragma mark - KVO CallBack
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if([object isEqual: _cropAreaView]) {
        if(_showMidLines){
            [self resetMidLines];
        }
        [self resetCropTransparentArea];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
