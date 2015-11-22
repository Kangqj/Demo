//
//  CentralOperateManager.h
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CentralOperateManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

typedef void (^FindSignalBlock)(CBPeripheral *peripheral);
typedef void (^ReceiveDataBlock)(NSString *path);
typedef void (^RSSIDataBlock)(NSInteger rssi);

@property(nonatomic, copy) FindSignalBlock findSignalBlock;
@property(nonatomic, copy) ReceiveDataBlock receiveBlock;
@property(nonatomic, copy) RSSIDataBlock rssieBlock;
@property(nonatomic, strong) CBPeripheral     *curPeripheral;

+ (CentralOperateManager *)sharedManager;

//搜索周边服务
- (void)scanPeripheralSignal:(FindSignalBlock)block;

//停止搜索
- (void)stopScanSign;

//连接周边服务
- (void)connectPeripheral;

//断开连接
- (void)disconnectPeripheral;

//接收数据
- (void)reciveData:(ReceiveDataBlock)receive;

//发送数据
- (void)sendData:(NSData *)data;

//获取RSSI强度
- (void)getRSSIData:(RSSIDataBlock)rssi;

@end
