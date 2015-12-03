//
//  PeripheralOperateManager.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "PeripheralOperateManager.h"

#define kBlock_length   150

@interface PeripheralOperateManager () <CBPeripheralManagerDelegate,CBPeripheralDelegate>
{
    NSTimer *timer;
    int  blokcNumber;
}

@property(nonatomic, strong) CBPeripheralManager *peripheralManager;
@property(nonatomic, strong) CBMutableCharacteristic *readwriteCharacteristic;

@end

@implementation PeripheralOperateManager

+ (PeripheralOperateManager *)sharedManager
{
    static PeripheralOperateManager *instance = nil;
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
        
        blokcNumber = 0;
    }
    
    return self;
}

- (void)startBroadcastService
{
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

/*
typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
    CBCharacteristicPropertyBroadcast=0x01,//广播,不允许本地特性
    CBCharacteristicPropertyRead=0x02,//可读
    CBCharacteristicPropertyWriteWithoutResponse=0x04,//可写,无反馈
    CBCharacteristicPropertyWrite=0x08,//可写
    CBCharacteristicPropertyNotify=0x10,//通知,无反馈
    CBCharacteristicPropertyIndicate=0x20,//标识
    CBCharacteristicPropertyAuthenticatedSignedWrites=0x40,//允许签名一个可写的特性
    CBCharacteristicPropertyExtendedProperties=0x80,//如果设置后，附加特性属性为一个扩展的属性说明，不允许本地特性
    CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)=0x100,//如果设置后，仅允许信任的设备可以打开通知特性值
    CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)=0x200//如果设置后，仅允许信任的设备可以打开标识特性值
};
 */

//添加服务
- (void)addServices
{
    CBUUID *descriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    self.readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:CharacteristicUUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: descriptionStringUUID value:@"name"];
    [self.readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    
    CBMutableService *service = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID] primary:YES];
    [service setCharacteristics:@[self.readwriteCharacteristic]];
    
    [self.peripheralManager addService:service];
}

- (void)stopBroadcastService
{
    [self.peripheralManager stopAdvertising];
    
    self.peripheralManager.delegate = nil;
    self.peripheralManager = nil;
}

//发送数据
- (void)sendPeripgeralData:(NSString *)string
{
    [self.peripheralManager updateValue:[string dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.readwriteCharacteristic onSubscribedCentrals:nil];
}

//接收数据
- (void)reciveData:(ReceiveDataBlock)receive
{
    self.receiveBlock = receive;
}


#pragma  mark -- CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state)
    {
        case CBPeripheralManagerStatePoweredOn:
            [self addServices];
            break;
        case CBPeripheralManagerStatePoweredOff:
            [self.peripheralManager stopAdvertising];
            break;
            
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error == nil)
    {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:ServiceUUID]],
                                                   CBAdvertisementDataLocalNameKey:NameKey}];
    }
    else
    {
        NSLog(@"didAddService:error:%@",error);
    }
}

//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    
}

//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    
}

//发送数据，发送当前时间的秒数
-(BOOL)sendDataIndex:(int)index
{
    NSData *segmentData = [self getBlockDataIn:blokcNumber blockLength:kBlock_length];
    
    /*
     type:       //消息类型
     data:       //图片数据
     index:      //序列号
     length:     //长度
     alllength:  //总长度
     */
    
    NSString *picPath = [[NSBundle mainBundle] pathForResource:@"icon_64" ofType:@"png"];
    NSData *fileData = [NSData dataWithContentsOfFile:picPath];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         TransferKey,@"type",
                         segmentData,@"data",
                         [NSNumber numberWithInt:index],@"index",
                         [NSNumber numberWithInt:kBlock_length],@"length",
                         [NSNumber numberWithLongLong:fileData.length],@"alllength",nil];
    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:dic forKey:ArchiverKey];
//    [archiver finishEncoding];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    return [self.peripheralManager updateValue:data forCharacteristic:self.readwriteCharacteristic onSubscribedCentrals:nil];
}

- (NSData *)getBlockDataIn:(int)index blockLength:(int)length
{
    NSString *picPath = [[NSBundle mainBundle] pathForResource:@"icon_64" ofType:@"png"];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:picPath];
    [handle seekToFileOffset:index*length];
    NSData *segmentData = [handle readDataOfLength:length];
    [handle closeFile];
    
    return segmentData;
}


//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    
    //判断是否有读数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        [request setValue:data];
        //对请求作出成功响应
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    
    CBATTRequest *request = requests[0];
    
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        NSString *dataStr = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        NSLog(@"didReceiveWriteRequests:%@",dataStr);
        
        if (request.value)
        {
//            NSError *error;
//            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.value options:kNilOptions error:&error];
            
            NSDictionary *dic= [NSKeyedUnarchiver unarchiveObjectWithData:request.value];
            
//            NSDictionary *dic = [NSDictionary dictionary];
//            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:request.value];
//            [unarchiver decodeObjectForKey:ArchiverKey];
//            [unarchiver finishDecoding];
            
            NSString *type = [dic objectForKey:@"type"];
            
            if ([type isEqualToString:BumpKey])
            {
                [self sendDataIndex:0];
                blokcNumber = 0;
            }
            else if ([type isEqualToString:TransferKey])
            {
                NSNumber *number = [dic objectForKey:@"index"];
                [self sendDataIndex:[number intValue]];
            }
        }
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
    
}

@end
