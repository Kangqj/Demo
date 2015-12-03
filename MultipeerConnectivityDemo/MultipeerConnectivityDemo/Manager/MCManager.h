//
//  Manager.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ FindPeer)(MCPeerID *peer);
typedef void (^ LosePeer)(MCPeerID *peer);

@interface MCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;//设备id
@property (nonatomic, strong) MCSession *session;//会话
@property (nonatomic, strong) MCNearbyServiceBrowser *myBrowser; //浏览器对象，可以搜索周边设备，然后进行自定义UI展示搜索出来的对等点列表
@property (nonatomic, strong) MCNearbyServiceAdvertiser *myAdvertiser; //控制设备是否能被搜索到，进行连接邀请时，提示框可自定义
@property (nonatomic, strong) FindPeer findPeerBlk;
@property (nonatomic, strong) LosePeer losePeerBlk;

+ (MCManager *)sharedManager;

//初始化peer和session
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;

//广播这个peer
- (void)advertisingPeer:(BOOL)isAdvertise;

//搜索附近的peer
- (void)browsingForPeers:(FindPeer)findPeer lose:(LosePeer)losePeer;

@end
