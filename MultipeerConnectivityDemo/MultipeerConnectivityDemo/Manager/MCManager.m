//
//  Manager.m
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import "MCManager.h"

/*
 每一个服务都应有一个类型（标示符），它是由ASCII字母、数字和“-”组成的短文本串，最多15个字符。
 通常，一个服务的名字应该由应用程序的名字开始，后边跟“-”和一个独特的描述符号。
 */
static NSString *const MyServiceType = @"chat-files";

@implementation MCManager

+ (MCManager *)sharedManager
{
    static MCManager *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self)
    {
        self = [super init];
        
    }
    
    return self;
}

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    self.session = [[MCSession alloc] initWithPeer:_peerID];
    self.session.delegate = self;
}


- (void)browsingForPeers:(FindPeer)findPeer lose:(LosePeer)losePeer;
{
    if (!self.myBrowser)
    {
        self.myBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:MyServiceType];
        self.myBrowser.delegate = self;
    }
    
    self.findPeerBlk = findPeer;
    self.losePeerBlk = losePeer;
    
    [self.myBrowser startBrowsingForPeers];
}

- (void)advertisingPeer:(BOOL)isAdvertise
{
    if (!self.myAdvertiser)
    {
        self.myAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:nil serviceType:MyServiceType];
        self.myAdvertiser.delegate = self;
    }
    
    if (isAdvertise)
    {
        [self.myAdvertiser startAdvertisingPeer];
    }
    else
    {
        [self.myAdvertiser stopAdvertisingPeer];
        self.myAdvertiser = nil;
    }
}

#pragma mark MCSessionDelegate

//节点状态改变，已连接或断开，MCSessionStateConnected , MCSessionStateConnecting  and  MCSessionStateNotConnected。最后一个状态在节点从连接断开后依然有效
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dict];
}

//接收到的数据，有三种数据可以交换：消息，流，和资源
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
}

//开始接收到资源文件
-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"progress"      :   progress
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidStartReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    });
}

//资源接收完成
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"localURL"      :   localURL
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}

//接收流数据
-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

#pragma mark MCNearbyServiceBrowserDelegate

//开启搜索失败
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    
}

//发现附近的设备
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
//    NSString *dataStr = @"Hello";
//    [self.myBrowser invitePeer:peerID toSession:_session withContext:[dataStr dataUsingEncoding:NSUTF8StringEncoding] timeout:20];
    self.findPeerBlk(peerID);
}

//某个设备丢失
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    self.losePeerBlk(peerID);
}

#pragma mark MCNearbyServiceAdvertiserDelegate
//接收到邀请
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    //其中：invitationHandler 这个参数是用来处理是否接收请求的,如下所示
    invitationHandler(YES,_session); //这就表示你接受邀请了，系统将会你们的设备进行匹配
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

@end
