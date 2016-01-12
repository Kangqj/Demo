//
//  PeerView.m
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/3.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import "PeerView.h"

@implementation PeerView
{
    CGPoint startPoint;
}

@synthesize peerID,ConnectPeer;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame peer:(MCPeerID *)peer color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.peerID = peer;
        
        UIButton *peerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        peerBtn.frame = CGRectMake((self.frame.size.width-100)/2, 0, 100, 100);
        [peerBtn addTarget:self action:@selector(pressAction) forControlEvents:UIControlEventTouchUpInside];
        [peerBtn setTitle:peer.displayName forState:UIControlStateNormal];
        [self addSubview:peerBtn];
        
        [peerBtn setBackgroundImage:[UIImage drawRoundImageWithColor:color size:peerBtn.frame.size] forState:UIControlStateNormal];
//        [peerBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:color size:CGSizeMake(100, 50)] forState:UIControlStateNormal];
        peerBtn.layer.cornerRadius = 50;
        peerBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        peerBtn.layer.shadowOffset = CGSizeMake(5, 5);
        peerBtn.layer.shadowOpacity = 0.6;
        
        flagLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 0, 20, 20)];
        flagLab.backgroundColor = [UIColor redColor];
        flagLab.layer.cornerRadius = 10;
        flagLab.text = @"1";
        flagLab.textAlignment = NSTextAlignmentCenter;
        flagLab.textColor = [UIColor whiteColor];
        flagLab.layer.masksToBounds = YES;
        [self addSubview:flagLab];
        flagLab.hidden = YES;
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 20)];
        [self addSubview:progressView];
        progressView.hidden = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        /*
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraBtn.frame = CGRectMake((self.frame.size.width-100)/2, 110, 50, 50);
        [cameraBtn setTitle:@"+" forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(gatoCameraView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cameraBtn];
        
        UIImage *cameraimage = [UIImage imageWithColor:color];
        [cameraBtn setBackgroundImage:[UIImage imageWithCornerRadius:50 image:cameraimage] forState:UIControlStateNormal];
        cameraBtn.layer.cornerRadius = 50;
        cameraBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        cameraBtn.layer.shadowOffset = CGSizeMake(5, 5);
        cameraBtn.layer.shadowOpacity = 0.6;*/
    }
    
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    pan.view.center = CGPointMake(pan.view.center.x + point.x, pan.view.center.y + point.y);
    [pan setTranslation:CGPointMake(0, 0) inView:self];
    
    return;
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [pan velocityInView:self];
        
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        
        CGFloat slideMult = magnitude / 200;
        
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        
        CGPoint finalPoint = CGPointMake(pan.view.center.x + (velocity.x * slideFactor),
                                         
                                         pan.view.center.y + (velocity.y * slideFactor));
        
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.bounds.size.width);
        
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            pan.view.center = finalPoint;
            
        } completion:nil];
    }
    else
    {
        CGPoint point = [pan translationInView:self];
        NSLog(@"%f,%f",point.x,point.y);
        pan.view.center = CGPointMake(pan.view.center.x + point.x, pan.view.center.y + point.y);
        [pan setTranslation:CGPointMake(0, 0) inView:self];
    }
}

- (void)loadProgress:(float)progress
{
    [UIView animateWithDuration:0.3 animations:^{
        if (progress == 0)
        {
            flagLab.hidden = NO;
            progressView.hidden = NO;
        }
        else if (progress == 1)
        {
            flagLab.hidden = YES;
            progressView.hidden = YES;
            
            [AnimationEngin shakeAnimation:self repeatCount:3];
        }
    }];
    
    [progressView setProgress:progress animated:YES];
}

- (void)pressAction
{
    self.ConnectPeer(self.peerID);
}

- (void)gatoCameraView
{
    
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    
    UITouch *touch = [touches anyObject];
    startPoint = [touch  locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch  locationInView:self.superview];
    
    self.frame = CGRectMake(point.x-startPoint.x, point.y-startPoint.y, self.frame.size.width, self.frame.size.height);
    
}
*/


@end
