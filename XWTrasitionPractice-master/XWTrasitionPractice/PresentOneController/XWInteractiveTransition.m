//
//  XWInteractiveTransition.m
//  XWTrasitionPractice
//
//  Created by YouLoft_MacMini on 15/11/24.
//  Copyright © 2015年 YouLoft_MacMini. All rights reserved.
//

#import "XWInteractiveTransition.h"
#import "XWMagicMovePushController.h"

@interface XWInteractiveTransition () <UIGestureRecognizerDelegate>
{
    float lastScale;
    
    float lastRotation;
}

@property (nonatomic, weak) UIViewController *vc;
/**手势方向*/
@property (nonatomic, assign) XWInteractiveTransitionGestureDirection direction;
/**手势类型*/
@property (nonatomic, assign) XWInteractiveTransitionType type;

@end

@implementation XWInteractiveTransition

+ (instancetype)interactiveTransitionWithTransitionType:(XWInteractiveTransitionType)type GestureDirection:(XWInteractiveTransitionGestureDirection)direction{
    return [[self alloc] initWithTransitionType:type GestureDirection:direction];
}

- (instancetype)initWithTransitionType:(XWInteractiveTransitionType)type GestureDirection:(XWInteractiveTransitionGestureDirection)direction{
    self = [super init];
    if (self) {
        _direction = direction;
        _type = type;
    }
    return self;
}

- (void)addPanGestureForViewController:(UIViewController *)viewController{
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    self.vc = viewController;
//    [viewController.view addGestureRecognizer:pan];
    
    self.vc = viewController;
    
//    XWMagicMovePushController *controller = (XWMagicMovePushController *)viewController;

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    pinch.delegate = self;
//    [controller.imageView addGestureRecognizer:pinch];
    [self.vc.view addGestureRecognizer:pinch];

    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    rotation.delegate = self;
//    [controller.imageView addGestureRecognizer:rotation];
//    [self.vc.view addGestureRecognizer:rotation];

    
    lastScale = 1.0;
    lastRotation = 0.0;
}

/**
 *  手势过渡的过程
 */
- (void)handleGesture:(UIPanGestureRecognizer *)panGesture{
    //手势百分比
    CGFloat persent = 0;
    switch (_direction) {
        case XWInteractiveTransitionGestureDirectionLeft:{
            CGFloat transitionX = -[panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case XWInteractiveTransitionGestureDirectionRight:{
            CGFloat transitionX = [panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case XWInteractiveTransitionGestureDirectionUp:{
            CGFloat transitionY = -[panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
        case XWInteractiveTransitionGestureDirectionDown:{
            CGFloat transitionY = [panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            //手势开始的时候标记手势状态，并开始相应的事件
            self.interation = YES;
            [self startGesture];
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            [self updateInteractiveTransition:persent];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            //手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否者取消转场操作
            self.interation = NO;
            if (persent > 0.5) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            
            [self finishInteractiveTransition];
            break;
        }
        default:
            break;
    }
}

- (void)startGesture{
    switch (_type) {
        case XWInteractiveTransitionTypePresent:{
            if (_presentConifg) {
                _presentConifg();
            }
        }
            break;
            
        case XWInteractiveTransitionTypeDismiss:
            [_vc dismissViewControllerAnimated:YES completion:nil];
            break;
        case XWInteractiveTransitionTypePush:{
            if (_pushConifg) {
                _pushConifg();
            }
        }
            break;
        case XWInteractiveTransitionTypePop:
            [_vc.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (void)pinchAction:(UIPinchGestureRecognizer *)sender
{
    NSLog(@"1---%f", sender.scale);
    
    float persent = 1.0 - sender.scale;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            //手势开始的时候标记手势状态，并开始相应的事件
            self.interation = YES;
            [self startGesture];
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            [self updateInteractiveTransition:persent];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            //手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否者取消转场操作
            self.interation = NO;
            [self finishInteractiveTransition];
            break;
        }
        default:
            break;
    }
    
    /*
    //当手指离开屏幕时,将lastscale设置为1.0
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [[(UIPinchGestureRecognizer*)sender view]setTransform:newTransform];
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
    */
//    //在原有transform的基础上再缩放
//    sender.view.transform =CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
//    //重置缩放比例为1
//    sender.scale = 1;
//    
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        sender.view.transform = CGAffineTransformIdentity;
//    }
}

- (void)rotatePiece:(UIRotationGestureRecognizer *)sender
{
    NSLog(@"2---%f", sender.rotation);
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    CGAffineTransform newTransform = CGAffineTransformRotate(sender.view.transform, rotation);
    [[(UIPinchGestureRecognizer*)sender view]setTransform:newTransform];
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    
//    //在原有transform的基础上再旋转
//    sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
//    //重置旋转角度为0
//    sender.rotation = 0;
//    
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        sender.view.transform = CGAffineTransformIdentity;
//    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;

//    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])//先进行捏合手势后，才往下进行旋转手势
//    {
//        return YES;
//    }
//    else
//    {
//        return  NO;
//    }
    
}

@end
