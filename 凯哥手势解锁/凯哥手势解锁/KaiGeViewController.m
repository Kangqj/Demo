//
//  KaiGeViewController.m
//  凯哥手势解锁
//
//  Created by 吴 凯 on 15/10/20.
//  Copyright © 2015年 kaigelaile. All rights reserved.
//

#import "KaiGeViewController.h"
#import "LockController.h"
@interface KaiGeViewController ()

@end

@implementation KaiGeViewController
- (IBAction)showGestureUnlockView:(UIButton *)sender {
    LockController *lockController = [[LockController alloc]init];
    [self presentViewController:lockController animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
