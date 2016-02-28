//
//  ViewController.m
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"
#import "PeerView.h"
#import "RadarView.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    RadarView *radarView;
    
    NSMutableArray *peerViewArr;
    MCPeerID       *curPeer;
}

@property (strong, nonatomic) NSMutableArray *peerViewArr;
@property (strong, nonatomic) MCPeerID       *curPeer;


@end

@implementation ViewController

@synthesize peerViewArr, curPeer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    radarView = [[RadarView alloc] initWithFrame:CGRectMake((kMainScreenWidth-50)/2, 20, 100, 100)];
    [self.view addSubview:radarView];
    [radarView start];
    
    self.peerViewArr = [NSMutableArray array];
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [[DataManager sharedManager] createSandboxFolder];
    
    //设备初始化
    [[MCManager sharedManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    
    //广播信号
    [[MCManager sharedManager] advertisingPeer:YES];
    [self addPeerView:nil];
    //搜索其他设备
    [[MCManager sharedManager] browsingForPeers:^(MCPeerID *peer) {
        
        [[DataManager sharedManager].peerArr addObject:peer];
        
        [self addPeerView:peer];
        
    } lose:^(MCPeerID *peer) {
        
        [[DataManager sharedManager].peerArr removeObject:peer];
        
        [self removePeerView:peer];
        
    }];
    
    //接收到邀请, 默认接受邀请
//    [[MCManager sharedManager] receiveInvitation:^(MCPeerID *peer, MCSession *session, InvitationHandler handle) {
//        
//        handle(YES,session);
//        
//    }];
    
    //收到消息
    [[MCManager sharedManager] receiveMessage:^(MCPeerID *peer, NSString *msg) {
        
        for (PeerView *view in self.peerViewArr)
        {
            if ([view.peerID.displayName isEqualToString:peer.displayName])
            {
                [AnimationEngin shakeAnimation:view repeatCount:3];
                break;
            }
        }
        
        [KProgressHUD showHUDWithText:msg delay:2 height:40];
    }];
    
    //收到文件
    [[MCManager sharedManager] receiveFile:^(MCPeerID *peer, float progress) {
        
        for (PeerView *view in self.peerViewArr)
        {
            if ([view.peerID.displayName isEqualToString:peer.displayName])
            {
                [view loadProgress:progress];
                
                break;
            }
        }
        
    }];
}

- (void)addPeerView:(MCPeerID *)peer
{
    PeerView *loseView = nil;
    
    for (PeerView *view in self.peerViewArr)
    {
        if ([view.peerID.displayName isEqualToString:peer.displayName])
        {
            loseView = view;
            break;
        }
    }
    
    if (loseView != nil)
    {
        return;
    }
    
    PeerView *peerView = [[PeerView alloc] initWithFrame:CGRectMake(100, 100, 150, 150) peer:peer color:[UIColor randomColor]];
    [self.view addSubview:peerView];
    [self.peerViewArr addObject:peerView];
    peerView.hidden = YES;
    
    [[MCManager sharedManager] invitePeer:peer];
    
    [peerView setConnectPeer:^(MCPeerID *peer) {
        [self removePeerView:peer];
        return ;
        self.curPeer = peer;
        UIImagePickerController *pickController = [[UIImagePickerController alloc] init];
        pickController.delegate = self;
        pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:pickController animated:YES completion:NULL];
        
//        [[MCManager sharedManager] sendMessage:@"hello" to:peer];
    }];
    
    [AnimationEngin popoverDismissAnimation:YES view:peerView dismissFinish:^(UIView *view) {
        
    }];
}

- (void)removePeerView:(MCPeerID *)peer
{
    PeerView *loseView = nil;
    
    for (PeerView *view in self.peerViewArr)
    {
        if ([view.peerID.displayName isEqualToString:peer.displayName])
        {
            loseView = view;
            break;
        }
    }
    
    if (loseView != nil)
    {
        [self.peerViewArr removeObject:loseView];
        
        [AnimationEngin popoverDismissAnimation:NO view:loseView dismissFinish:^(UIView *view) {
            
            PeerView *peerView = (PeerView *)view;
            [peerView removeFromSuperview];
            
        }];
    }
}

- (void)goToChat
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    [self presentViewController:chatViewController animated:YES completion:NULL];
}

#pragma -mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /*
     Printing description of info:
     {
     UIImagePickerControllerMediaType = "public.image";
     UIImagePickerControllerOriginalImage = "<UIImage: 0x175c6e40> size {1936, 2592} orientation 3 scale 1.000000";
     UIImagePickerControllerReferenceURL = "assets-library://asset/asset.JPG?id=4007A4D4-819F-4A3A-8600-AEE1684C3CFF&ext=JPG";
     }
     */
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[DataManager sharedManager].downPath error:nil];
        NSString *name = [NSString stringWithFormat:@"image_%ld.jpg",fileArr.count + 1];
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString *filePath = [[DataManager sharedManager].bufferPath stringByAppendingPathComponent:name];
        [data writeToFile:filePath atomically:NO];
        [[MCManager sharedManager] sendFile:filePath to:self.curPeer];
    });
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end