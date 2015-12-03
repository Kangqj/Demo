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
    int curIndex;
}

@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property(nonatomic, strong) NSTimer          *timer;
@property(nonatomic, strong) NSMutableData    *buffer;


@end

@implementation CentralOperateManager

@synthesize curPeripheral;

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
        
        self.buffer = [NSMutableData data];
    }
    
    return self;
}

- (void)scanPeripheralSignal:(FindSignalBlock)block;
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.findSignalBlock = block;
}

- (void)connectPeripheral
{
    [self.centralManager connectPeripheral:self.curPeripheral options:nil];
    //@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}
}

- (void)disconnectPeripheral
{
    [self.centralManager cancelPeripheralConnection:self.curPeripheral];
}

- (void)stopScanSign
{
    [self.centralManager stopScan];
    
    self.centralManager.delegate = nil;
    self.centralManager = nil;
}


- (void)getRSSIData:(RSSIDataBlock)rssi
{
    self.rssieBlock = rssi;
}

- (float)calcDistByRSSI:(int)rssi
{
    int iRssi = abs(rssi);
    float power = (iRssi-59)/(10*2.0);
    return pow(10, power);
}


- (void)reciveData:(ReceiveDataBlock)receive
{
    self.receiveBlock = receive;
}


- (void)sendData:(NSData *)data
{
    if (self.writeCharacteristic)
    {
        [self.curPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            
            [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];//已发现的设备是否重复扫描
            
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.findSignalBlock(peripheral);
    
    [self.centralManager stopScan];
    
    if (self.curPeripheral != peripheral)
    {
        self.curPeripheral = peripheral;
        
//        [self.centralManager connectPeripheral:self.curPeripheral options:nil];
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:ServiceUUID]]];
    
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:peripheral
                                                selector:@selector(readRSSI)
                                                userInfo:nil
                                                 repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

#pragma mark CBPeripheralDelegate
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!error)
    {
        if (self.rssieBlock)
        {
            self.rssieBlock([[peripheral RSSI] intValue]);
            
            if ([[peripheral RSSI] intValue] > -36)
            {
//                [self sendData:BumpKey];
            }
        }
        
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        for (CBService *service in peripheral.services)
        {
            NSLog(@"Service found with UUID: %@",service.UUID);
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CharacteristicUUID]] forService:service];
        }
    }
    else
    {
        NSLog(@"didDiscoverServices Error:%@", [error localizedDescription]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error discovering characteristic:%@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        self.writeCharacteristic = characteristic;
        
        [peripheral readValueForCharacteristic:characteristic];
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.value)
    {
        /*key
         type:       //消息类型
         data:       //图片数据
         index:      //序列号
         length:     //长度
         alllength:  //总长度
         */
        
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/bb"];
        [characteristic.value writeToFile:path atomically:YES];
        
//        NSError *error;
//        NSDictionary *dic = [[NSDictionary alloc] init];
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:characteristic.value];
//        [unarchiver decodeObjectForKey:ArchiverKey];
//        [unarchiver finishDecoding];
        
//        NSDictionary *dic= [NSKeyedUnarchiver unarchiveObjectWithData:characteristic.value];
        NSDictionary *dic= [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        NSString *type = [dic objectForKey:@"type"];
        
        if ([type isEqualToString:TransferKey])
        {
            NSNumber *index = [dic objectForKey:@"index"];
            curIndex = [index intValue];
            
            if (0 == [index intValue]) {
                self.buffer = nil;
                self.buffer = [NSMutableData data];
            }
            
            NSData *data = [dic objectForKey:@"data"];
            [self.buffer appendData:data];
            
            NSNumber *lengthNum = [dic objectForKey:@"alllength"];
            long long alllength = [lengthNum longLongValue];
            
            if (self.buffer.length >= alllength)
            {
                NSString *path = [NSHomeDirectory() stringByAppendingString:@"/image.png"];
                
                if (self.receiveBlock && [self.buffer writeToFile:path atomically:NO])
                {
                    self.receiveBlock(path);
                }
            }
        }
    }
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
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             BumpKey,@"type",
                             [NSNumber numberWithInt:curIndex],@"index",nil];
        
//        NSError *errors;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&errors];
//        NSMutableData *data = [[NSMutableData alloc] init];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:dic forKey:ArchiverKey];
//        [archiver finishEncoding];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        
        [self sendData:data];
    }
    else
    {
        NSLog(@"Notification stopped on %@.Disconnecting", characteristic);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

//写数据回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         TransferKey,@"type",
                         [NSNumber numberWithInt:curIndex],@"index",nil];
    
//    NSError *errors;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&errors];
    
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:dic forKey:ArchiverKey];
//    [archiver finishEncoding];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [self sendData:data];
}
/*
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
}*/

@end