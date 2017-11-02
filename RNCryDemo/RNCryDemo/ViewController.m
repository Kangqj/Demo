//
//  ViewController.m
//  RNCryDemo
//
//  Created by kangqijun on 2017/11/2.
//  Copyright © 2017年 Kangqijun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(20, 100, 80, 40);
    [button1 setTitle:@"加密" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(encryData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(120, 100, 80, 40);
    [button2 setTitle:@"解密" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(dencryData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)encryData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSString *pwd = @"key";
    
    NSError *error;
    
    NSData *encryData = [RNEncryptor encryptData:data
                                   withSettings:kRNCryptorAES256Settings
                                       password:pwd
                                           error:&error];
    [encryData writeToFile:@"/Users/kangqijun/Desktop/aaa.png" atomically:YES];
}

- (void)dencryData
{
    NSString *path = @"/Users/kangqijun/Desktop/aaa.png";
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSString *pwd = @"key";
    
    NSError *error;
    NSData *encryData = [RNDecryptor decryptData:data
                                    withPassword:pwd
                                           error:&error];
    
    [encryData writeToFile:@"/Users/kangqijun/Desktop/bbb.png" atomically:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
