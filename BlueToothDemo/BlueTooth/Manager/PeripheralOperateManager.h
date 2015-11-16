//
//  PeripheralOperateManager.h
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralOperateManager : NSObject

typedef void (^ReceiveDataBlock)(NSString *path);
@property(nonatomic, copy) ReceiveDataBlock receiveBlock;


+ (PeripheralOperateManager *)sharedManager;

- (void)startBroadcastService;
- (void)stopBroadcastService;

//接收数据
- (void)reciveData:(ReceiveDataBlock)receive;

//发送数据
- (void)sendPeripgeralData:(NSString *)string;

@end
