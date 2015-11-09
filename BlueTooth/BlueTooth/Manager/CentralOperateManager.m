//
//  CentralOperateManager.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "CentralOperateManager.h"

@interface CentralOperateManager ()
{
    BOOL isNear;
}

@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property(nonatomic, assign) NSInteger peripheralIndex;
@property(nonatomic, assign) NSInteger serviceIndex;
@property(nonatomic, assign) NSTimer   *timer;


@end

@implementation CentralOperateManager

+ (CentralOperateManager *)sharedManager
{
    static CentralOperateManager *instance = nil;
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
        
        self.peripheralArr = [NSMutableArray array];
        self.dataDicArr = [NSMutableArray array];
        
        isNear = NO;
    }
    
    return self;
}

- (void)reflashScan
{
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)startScanWithFinish:(ScanFinishBlock)completion
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //开始扫描寻找制定的服务（根据UUID寻找），若为nil，则是寻找周边所有的服务
    //[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    
    [self.peripheralArr removeAllObjects];
    [self.dataDicArr removeAllObjects];
    
    self.scanFinishBlock = completion;
    self.scanFinishBlock();
}

- (void)stopScan
{
    [self.centralManager stopScan];
    
    self.centralManager.delegate = nil;
    self.centralManager = nil;
}

//获取RSSI强度
- (void)getRSSIData:(RSSIDataBlock)rssi
{
    self.rssieBlock = rssi;
}

#pragma mark 找到服务回调
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BOOL hasSame = NO;
    
    for (CBPeripheral *per in self.peripheralArr)
    {
        if ([per.name isEqualToString:peripheral.name])
        {
            hasSame = YES;
        }
    }
    
    if (hasSame == NO)
    {
        [self.peripheralArr addObject:peripheral];
        
        NSArray *arr = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        
        if (arr.count != 0 && [RSSI intValue] != 0)
        {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:peripheral.name,@"name",arr,@"UUIDs",RSSI,@"RSSI", nil];
            [self.dataDicArr addObject:dic];
        }
    }
    
    self.scanFinishBlock();
}

- (void)connectPeripheral:(NSInteger)index service:(NSInteger)sIndex
{
    if (self.peripheralArr.count > index)
    {
        self.peripheralIndex = index;
        self.serviceIndex = sIndex;
        
        CBPeripheral *peripheral = [self.peripheralArr objectAtIndex:index];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    else
    {
        NSLog(@"数组越界");
    }
}

- (void)disconnectCurPeripheral
{
    if (self.peripheralArr.count > self.peripheralIndex)
    {
        CBPeripheral *peripheral = [self.peripheralArr objectAtIndex:self.peripheralIndex];
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

//接收数据
- (void)reciveData:(ReceiveDataBlock)receive
{
    self.receiveBlock = receive;
}

//发送数据
- (void)sendData:(NSString *)string
{
    if (self.writeCharacteristic)
    {
        CBPeripheral *peripheral = [self.peripheralArr objectAtIndex:self.peripheralIndex];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSLog(@"没有写入权限");
    }
    
}

#pragma mark 连接服务结果回调
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //让周边去发现这个服务
    NSDictionary *dic = [self.dataDicArr objectAtIndex:self.peripheralIndex];
    NSArray *arr = [dic objectForKey:@"UUIDs"];
    
    if (arr.count > self.serviceIndex)
    {
        CBUUID *uuid = [arr objectAtIndex:self.serviceIndex];
        [peripheral setDelegate:self];
        [peripheral discoverServices:@[uuid]];
        
        isNear = NO;
        if (self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:peripheral
                                                    selector:@selector(readRSSI)
                                                    userInfo:nil
                                                     repeats:1.0];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!error)
    {
        NSLog(@"rssi %d", [[peripheral RSSI] intValue]);
        
        if ([[peripheral RSSI] intValue] > -36 && isNear == NO)//说明靠近了，那么发送数据
        {
            [self sendData:@"near"];
            isNear = YES;
        }
        
        self.rssieBlock([[peripheral RSSI] intValue]);
    }
}

#pragma mark CBPeripheralDelegate 周边接收回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering service:%@", [error localizedDescription]);
        return;
    }
    
    //找到需要的那个服务，然后将特征给这个服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@",service.UUID);
        
        NSLog(@"%d-%d",service.includedServices.count,service.characteristics.count);
        
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            NSLog(@"characteristic found with UUID: %@",characteristic.UUID);
        }
        
        //FFF2特性具有读写权限
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFF2"]] forService:service];
    }
}

#pragma mark 特征的值更新回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if (characteristic.properties & CBCharacteristicPropertyWrite)
        {
            self.writeCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else
        {
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
      [peripheral discoverDescriptorsForCharacteristic:characteristic];
      [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    
    NSString *dataStr = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"characteristic uuid:%@  value:%@ string:%@",characteristic.UUID,characteristic.value,dataStr);
    self.receiveBlock(dataStr);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error changing notification state:%@", error.localizedDescription);
    }
    
    if (characteristic.isNotifying)
    {
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
    else
    {
        NSLog(@"Notification stopped on %@.Disconnecting", characteristic);
        //        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//写数据回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}

@end