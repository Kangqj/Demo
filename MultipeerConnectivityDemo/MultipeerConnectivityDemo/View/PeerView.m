//
//  PeerView.m
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/3.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import "PeerView.h"

@implementation PeerView

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
        peerBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [peerBtn addTarget:self action:@selector(pressAction) forControlEvents:UIControlEventTouchUpInside];
        [peerBtn setTitle:peer.displayName forState:UIControlStateNormal];
        [self addSubview:peerBtn];
        
        UIImage *image = [UIImage imageWithColor:color];
        [peerBtn setBackgroundImage:[UIImage imageWithCornerRadius:50 image:image] forState:UIControlStateNormal];
        peerBtn.layer.cornerRadius = 50;
        peerBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        peerBtn.layer.shadowOffset = CGSizeMake(5, 5);
        peerBtn.layer.shadowOpacity = 0.6;
    }
    
    return self;
}

- (void)pressAction
{
    self.ConnectPeer(self.peerID);
}

@end
