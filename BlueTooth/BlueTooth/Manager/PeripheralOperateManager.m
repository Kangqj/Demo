//
//  PeripheralOperateManager.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "PeripheralOperateManager.h"

@interface PeripheralOperateManager () <CBPeripheralManagerDelegate,CBPeripheralDelegate>
{
    int serviceNum;
    NSTimer *timer;
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
    }
    
    return self;
}

- (void)createService
{
    //characteristics字段描述
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:notiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
     */
    self.readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readwriteCharacteristicUUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [self.readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    
    /*
     只读的Characteristic
     properties：CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID1] primary:YES];
    NSLog(@"%@",service1.UUID);
    
    [service1 setCharacteristics:@[notiyCharacteristic,self.readwriteCharacteristic]];
    
    //service2初始化并加入一个characteristics
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID2] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
    [self.peripheralManager addService:service1];
    [self.peripheralManager addService:service2];
}

- (void)startBroadcastService
{
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}


- (void)stopBroadcastService
{
    [self.peripheralManager stopAdvertising];
    
    self.peripheralManager.delegate = nil;
    self.peripheralManager = nil;
    serviceNum = 0;
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
//peripheralManager状态改变
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
            //在这里判断蓝牙设别的状态  当开启了则可调用  setUp方法(自定义)
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"powered on");
            [self createService];
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"powered off");
            break;
            
        default:
            break;
    }
}

//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        serviceNum++;
    }
    
    //因为我们添加了2个服务，所以想两次都添加完成后才去发送广播
    if (serviceNum==2) {
        //添加服务后可以在此向外界发出通告 调用完这个方法后会调用代理的
        //(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
        [self.peripheralManager startAdvertising:@{
                                                   CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:ServiceUUID1],[CBUUID UUIDWithString:ServiceUUID2]],
                                                   CBAdvertisementDataLocalNameKey : LocalNameKey
                                                   }
         ];
        
    }
    
}

//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"in peripheralManagerDidStartAdvertisiong");
}

//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
    //每秒执行一次给主设备发送一个当前时间的秒数
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:characteristic  repeats:YES];
}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消订阅 %@的数据",characteristic.UUID);
    //取消回应
    [timer invalidate];
}

//发送数据，发送当前时间的秒数
-(BOOL)sendData:(NSTimer *)t {
    CBMutableCharacteristic *characteristic = t.userInfo;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"%@",[dft stringFromDate:[NSDate date]]);
    
    //执行回应Central通知数据
    return  [self.peripheralManager updateValue:[[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];
}


//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
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
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];
    
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        //需要转换成CBMutableCharacteristic对象才能进行写值
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        NSString *dataStr = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        NSLog(@"%@",dataStr);
        
        if ([dataStr isEqualToString:@"near"])
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:self.readwriteCharacteristic  repeats:YES];
        }
        
        self.receiveBlock(dataStr);
        
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
    
    
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
    
}

@end
