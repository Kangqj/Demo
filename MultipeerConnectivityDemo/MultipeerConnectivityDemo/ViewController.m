//
//  ViewController.m
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

@interface ViewController ()
{
    UIButton *peerBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
    
    //设备初始化
    [[MCManager sharedManager] setupPeerAndSessionWithDisplayName:@"A"];
    
    //广播信号
    [[MCManager sharedManager] advertisingPeer:YES];
    
    //搜索其他设备
    [[MCManager sharedManager] browsingForPeers:^(MCPeerID *peer) {
        
        [[DataManager sharedManager].peerArr addObject:peer];
        
        [self findLoseAnimation:YES peer:peer];
        
    } lose:^(MCPeerID *peer) {
        
        [[DataManager sharedManager].peerArr removeObject:peer];
        
        [self findLoseAnimation:NO peer:peer];
        
    }];
}

- (void)setupUI
{
    peerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    peerBtn.frame = CGRectMake(120, 210, 100, 100);
    [peerBtn addTarget:self action:@selector(goToChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peerBtn];
    UIImage *image = [UIImage imageWithColor:[UIColor randomColor]];
    [peerBtn setBackgroundImage:[UIImage imageWithCornerRadius:50 image:image] forState:UIControlStateNormal];
    peerBtn.layer.cornerRadius = 50;
    peerBtn.layer.shadowColor = [UIColor grayColor].CGColor;
    peerBtn.layer.shadowOffset = CGSizeMake(5, 5);
    peerBtn.layer.shadowOpacity = 0.6;
    peerBtn.hidden = YES;
}

- (void)goToChat
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    [self presentViewController:chatViewController animated:YES completion:NULL];
}

- (void)findLoseAnimation:(BOOL)isFind peer:(MCPeerID *)peer
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    
    NSMutableArray *values = [NSMutableArray array];
    
    if (isFind)
    {
        peerBtn.hidden = NO;
        [peerBtn setTitle:peer.displayName forState:UIControlStateNormal];
        
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    }
    else
    {
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.delegate = self;
    }
    
    animation.values = values;
    [peerBtn.layer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        peerBtn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end