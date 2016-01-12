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

- (void)invitePeer:(MCPeerID *)peer
{
    [self.myBrowser invitePeer:peer toSession:self.session withContext:nil timeout:10];
}

- (void)receiveInvitation:(ReceiveInvite)inviteBlk
{
    self.receiveInviteBlk = inviteBlk;
}

- (void)sendMessage:(NSString *)msg to:(MCPeerID *)peer
{
    NSData *dataToSend = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    [self.session sendData:dataToSend toPeers:@[peer]
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)receiveMessage:(ReceiveMsg)msgblk
{
    self.receiveMsg = msgblk;
}

- (void)sendFile:(NSString *)path to:(MCPeerID *)peer
{
    [self.session sendResourceAtURL:[NSURL fileURLWithPath:path] withName:[path lastPathComponent] toPeer:peer withCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else{
            
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KProgressHUD showHUDWithText:@"发送完成" delay:2.0 height:40];
            });
            
        }
        
    }];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [progress addObserver:self
//                   forKeyPath:@"fractionCompleted"
//                      options:NSKeyValueObservingOptionNew
//                      context:nil];
//    });
}

- (void)receiveFile:(ReceiveFile)receive
{
    self.receivefile = receive;
}

#pragma mark MCSessionDelegate

//节点状态改变，已连接或断开，MCSessionStateConnected , MCSessionStateConnecting  and  MCSessionStateNotConnected。最后一个状态在节点从连接断开后依然有效
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    switch (state) {
        case MCSessionStateNotConnected:
        {
            NSLog(@"连接断开");
            self.losePeerBlk(peerID);
            
            NSLog(@"---%@",self.session.connectedPeers);
            break;
        }
        case MCSessionStateConnecting:
        {
            NSLog(@"正在连接");
            break;
        }
        case MCSessionStateConnected:
        {
            NSLog(@"连接成功");
            self.findPeerBlk(peerID);
            break;
        }
            
        default:
            break;
    }
}

//接收到的数据，有三种数据可以交换：消息，流，和资源
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.receiveMsg(peerID, msg);
    });
}

//开始接收到资源文件
-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
        
        self.receivePeer = peerID;
        self.receivefile(peerID,0.0);
    });
}

//资源接收完成
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    if (error == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.receivefile(peerID, 1.0);
            
            NSArray *fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[DataManager sharedManager].downPath error:nil];
            NSString *name = [NSString stringWithFormat:@"image_%ld.jpg",fileArr.count + 1];
            
            NSString *destinationPath = [[DataManager sharedManager].downPath stringByAppendingPathComponent:name];
            NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager copyItemAtURL:localURL toURL:destinationURL error:&error];
            
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            UIImage *image = [UIImage imageWithContentsOfFile:destinationPath];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            
        });
        
    }
    else
    {
        NSLog(@"%@",error.description);
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL)
    {
        msg = @"保存图片失败" ;
        
    }else{
        msg = @"保存图片成功" ;
        
    }
    
    [KProgressHUD showHUDWithText:msg delay:2.0 height:40];
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
    
    NSLog(@"接受邀请");
//    self.receiveInviteBlk(peerID, _session, invitationHandler);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.receivefile(self.receivePeer,progress.fractionCompleted);
    });
}

@end
