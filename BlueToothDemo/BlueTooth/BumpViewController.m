//
//  BumpViewController.m
//  BlueToothDemo
//
//  Created by coverme on 15/11/11.
//  Copyright (c) 2015年 coverme. All rights reserved.
//

#import "BumpViewController.h"

@interface BumpViewController ()

@end

@implementation BumpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *rssiLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
    rssiLab.textColor = [UIColor blackColor];
    rssiLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:rssiLab];
    [[CentralOperateManager sharedManager] getRSSIData:^(NSInteger rssi) {
        rssiLab.text = [NSString stringWithFormat:@"RSSI:%d",rssi];
    }];
    
    UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:picImageView];
    picImageView.center = self.view.center;
    
    [[CentralOperateManager sharedManager] reciveData:^(NSString *path) {
        
        picImageView.image = [UIImage imageWithContentsOfFile:path];
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
