//
//  PeripheralViewController.m
//  BlueTooth
//
//  Created by Kangqj on 15/11/2.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import "PeripheralViewController.h"

@interface PeripheralViewController ()
{
    UITextField *inputField;
    UITextView  *showTextView;
}
@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"广播方";
    
    [[PeripheralOperateManager sharedManager] startBroadcastService];
    
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PeripheralOperateManager sharedManager] stopBroadcastService];
}

- (void)initUI
{
    showTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 65, self.view.frame.size.width-40, 90)];
    showTextView.layer.borderWidth = 1.0;
    showTextView.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:showTextView];
    showTextView.editable = NO;
    
    [[PeripheralOperateManager sharedManager] reciveData:^(NSString *string) {
        if (string.length == 0)
        {
            return ;
        }
        NSString *oriStr = showTextView.text;
        oriStr = [oriStr stringByAppendingFormat:@"%@-",string];
        showTextView.text = oriStr;
    }];
    
    inputField = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, self.view.frame.size.width-40, 40)];
    inputField.placeholder = @"请输入内容";
    inputField.layer.borderWidth = 1.0;
    inputField.layer.borderColor = [UIColor grayColor].CGColor;
    inputField.text = @"测试b";
    [self.view addSubview:inputField];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(20, 210, self.view.frame.size.width-40, 40);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [sendBtn addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.backgroundColor = [UIColor grayColor];
    sendBtn.layer.cornerRadius = 10;
    [self.view addSubview:sendBtn];
}

- (void)sendData
{
    [[PeripheralOperateManager sharedManager] sendPeripgeralData:inputField.text];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [inputField resignFirstResponder];
}

@end
