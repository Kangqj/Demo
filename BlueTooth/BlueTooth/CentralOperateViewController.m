//
//  CentralOperateViewController.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "CentralOperateViewController.h"

@interface CentralOperateViewController ()
{
    UITextField *inputField;
    UITextView  *showTextView;
    UILabel *rssiLab;
}

@end

@implementation CentralOperateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"接收方";
    
    [self initUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[CentralOperateManager sharedManager] disconnectCurPeripheral];
    
    [rssiLab removeFromSuperview];
}

- (void)initUI
{
    showTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 65, self.view.frame.size.width-40, 90)];
    showTextView.layer.borderWidth = 1.0;
    showTextView.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:showTextView];
    showTextView.editable = NO;
    
    inputField = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, self.view.frame.size.width-40, 40)];
    inputField.placeholder = @"请输入内容";
    inputField.layer.borderWidth = 1.0;
    inputField.layer.borderColor = [UIColor grayColor].CGColor;
    inputField.text = @"测试";
//    [self.view addSubview:inputField];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(20, 210, self.view.frame.size.width-40, 40);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [sendBtn addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.backgroundColor = [UIColor grayColor];
    sendBtn.layer.cornerRadius = 10;
    [self.view addSubview:sendBtn];
    
    [[CentralOperateManager sharedManager] reciveData:^(NSString *string) {
        if (string.length == 0)
        {
            return ;
        }
        NSString *oriStr = showTextView.text;
        oriStr = [oriStr stringByAppendingFormat:@"%@-",string];
        showTextView.text = oriStr;
    }];
    
    
    rssiLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 0, 100, 44)];
    rssiLab.textColor = [UIColor blackColor];
    rssiLab.textAlignment = NSTextAlignmentRight;
    rssiLab.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:rssiLab];
    [self.navigationController.navigationBar addSubview:rssiLab];
    
    [[CentralOperateManager sharedManager] getRSSIData:^(NSInteger rssi) {
       
        rssiLab.text = [NSString stringWithFormat:@"信号强度:%d",rssi];
        
    }];
}

- (void)sendData
{
    [[CentralOperateManager sharedManager] sendData:inputField.text];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [inputField resignFirstResponder];
}

@end
