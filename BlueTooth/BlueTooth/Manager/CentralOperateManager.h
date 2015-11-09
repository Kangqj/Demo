//
//  CentralOperateManager.h
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CentralOperateManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

typedef void (^ScanFinishBlock)();
typedef void (^ReceiveDataBlock)(NSString *string);
typedef void (^RSSIDataBlock)(NSInteger rssi);

@property(nonatomic, strong) NSMutableArray *peripheralArr;
@property(nonatomic, strong) NSMutableArray *dataDicArr;
@property(nonatomic, strong) ScanFinishBlock scanFinishBlock;
@property(nonatomic, strong) ReceiveDataBlock receiveBlock;
@property(nonatomic, strong) RSSIDataBlock rssieBlock;


+ (CentralOperateManager *)sharedManager;

//搜索周边服务
- (void)startScanWithFinish:(ScanFinishBlock)completion;
//停止搜索
- (void)stopScan;

//选区周边和服务
- (void)connectPeripheral:(NSInteger)index service:(NSInteger)sIndex;

//接收数据
- (void)reciveData:(ReceiveDataBlock)receive;

//断开连接
- (void)disconnectCurPeripheral;

//发送数据
- (void)sendData:(NSString *)string;

//刷新重新搜索
- (void)reflashScan;

//获取RSSI强度
- (void)getRSSIData:(RSSIDataBlock)rssi;

@end
