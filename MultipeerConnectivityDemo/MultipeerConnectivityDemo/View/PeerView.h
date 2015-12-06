//
//  PeerView.h
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/3.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerView : UIView
{
    UILabel *flagLab;
    UIProgressView *progressView;
}

@property (strong, nonatomic) MCPeerID *peerID;
@property (copy, nonatomic) void (^ConnectPeer)(MCPeerID *peer);

- (instancetype)initWithFrame:(CGRect)frame peer:(MCPeerID *)peer color:(UIColor *)color;

- (void)loadProgress:(float)progress;

@end
