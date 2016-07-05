//
//  ARCTwoBlocksViewController.m
//  BlockTest
//
//  Created by 康起军 on 16/5/29.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ARCTwoBlocksViewController.h"

@interface ARCTwoBlocksViewController ()


@end

@implementation ARCTwoBlocksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showDifferentBlock];
}

- (void)showDifferentBlock
{
    NSString * (^block1)() = ^
    {
        NSString *str = @"block1";
        
        return str;
    };
    
    NSString *str = @"block1";
    NSString * (^block2)() = ^
    {
        return str;
    };
    
    
//    NSString * (^block3)()  = Block_copy(block2);
    NSString * (^block4)()  = [block2 copy];
    
    NSLog(@"block1-> %@", block1);
    NSLog(@"block2-> %@", block2);
//    NSLog(@"block3-> %@", block3);
    NSLog(@"block4-> %@", block4);
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
