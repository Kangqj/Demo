
//  Manager.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ FindPeer)(MCPeerID *peer);
typedef void (^ LosePeer)(MCPeerID *peer);

typedef void (^ InvitationHandler)(BOOL accept, MCSession *session);
typedef void (^ ReceiveInvite)(MCPeerID *peer, MCSession *session, InvitationHandler handle);

typedef void (^ ReceiveMsg)(MCPeerID *peer, NSString *msg);
typedef void (^ ReceiveFile)(MCPeerID *peer, float progress);

@interface MCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;//设备id
@property (nonatomic, strong) MCSession *session;//会话
@property (nonatomic, strong) MCNearbyServiceBrowser *myBrowser; //浏览器对象，可以搜索周边设备，然后进行自定义UI展示搜索出来的对等点列表
@property (nonatomic, strong) MCNearbyServiceAdvertiser *myAdvertiser; //控制设备是否能被搜索到，进行连接邀请时，提示框可自定义

@property (nonatomic, copy) FindPeer findPeerBlk;
@property (nonatomic, copy) LosePeer losePeerBlk;
@property (nonatomic, copy) ReceiveInvite receiveInviteBlk;
@property (nonatomic, copy) ReceiveMsg receiveMsg;
@property (nonatomic, copy) ReceiveFile receivefile;
@property (nonatomic, strong) MCPeerID *receivePeer;


+ (MCManager *)sharedManager;

//初始化peer和session
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;

//广播这个peer
- (void)advertisingPeer:(BOOL)isAdvertise;

//搜索附近的peer
- (void)browsingForPeers:(FindPeer)findPeer lose:(LosePeer)losePeer;

//发起邀请建立连接
- (void)invitePeer:(MCPeerID *)peer;

//接收到别人的邀请
- (void)receiveInvitation:(ReceiveInvite)inviteBlk;

//发送文字消息
- (void)sendMessage:(NSString *)msg to:(MCPeerID *)peer;
//接收到文字消息
- (void)receiveMessage:(ReceiveMsg)msgblk;

//发送文件
- (void)sendFile:(NSString *)path to:(MCPeerID *)peer;
//接收到文件
- (void)receiveFile:(ReceiveFile)receive;


@end
