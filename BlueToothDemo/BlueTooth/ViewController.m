//
//  ViewController.m
//  BlueTooth
//
//  Created by Kangqj on 15/10/30.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"
#import "CentralViewController.h"
#import "PeripheralViewController.h"

@interface ViewController ()
{
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"选择角色";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *broadcast = [UIButton buttonWithType:UIButtonTypeCustom];
    broadcast.frame = CGRectMake(20, 80, self.view.frame.size.width-40, 40);
    [broadcast setTitle:@"广播方（Peripheral）" forState:UIControlStateNormal];
    broadcast.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    UIImage *oriImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"5dc68f"] size:CGSizeMake(self.view.frame.size.width-40, 40)];
    [broadcast setBackgroundImage:[UIImage imageWithCornerRadius:10 image:oriImage] forState:UIControlStateNormal];
    [self.view addSubview:broadcast];
    [broadcast addTarget:self action:@selector(broadcastService) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *recive = [UIButton buttonWithType:UIButtonTypeCustom];
    recive.frame = CGRectMake(20, 160, self.view.frame.size.width-40, 40);
    [recive setTitle:@"接收方（Central）" forState:UIControlStateNormal];
    recive.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    oriImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#cccccc"] size:CGSizeMake(self.view.frame.size.width-40, 40)];
    [recive setBackgroundImage:[UIImage imageWithCornerRadius:10 image:oriImage] forState:UIControlStateNormal];
    [self.view addSubview:recive];
    [recive addTarget:self action:@selector(reciveService) forControlEvents:UIControlEventTouchUpInside];
}

- (void)broadcastService
{
    PeripheralViewController *vc = [[PeripheralViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reciveService
{
    CentralViewController *vc = [[CentralViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark locationManager delegate



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
