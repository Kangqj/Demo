//
//  ARCCaptureVarViewController.m
//  BlockTest
//
//  Created by 康起军 on 16/6/4.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ARCCaptureVarViewController.h"

@interface ARCCaptureVarViewController ()
{
    NSString *string1;
}

@property (strong, nonatomic) NSString *string1;

@end

@implementation ARCCaptureVarViewController
@synthesize string1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showDifferentBlock];
}

- (void)showDifferentBlock
{
    int a = 1;
    int (^block1)(int) = ^(int b)
    {
        int c = a;
        
        return c;
    };
    
    NSLog(@"block1-> %@ block1:%d", block1, block1(1));
    
    __block int ai = 2;
    int (^block2)(int) = ^(int bi)
    {
        ai = bi;
        
        return ai;
    };
    
    NSLog(@"block2-> %@ block2:%d ai:%d", block2, block2(2), ai);
    
    /*
    //2.局部block
    NSString * (^block2)(NSString *) = ^(NSString *a)
    {
        return [a stringByAppendingString:@"000"];
    };
    
    NSLog(@"block2-> %@", block2);
    
    //block中使用局部变量
    __block NSString *str = @"4";
    NSString * (^block4)(NSString *) = ^(NSString *a)
    {
        str = [str stringByAppendingString:@"000"];
        NSLog(@"%@", str);
        
        return str;
    };
    
    NSLog(@"block4-> %@", block4);
    
    __block typeof(self)weakSelf = self;
    
    //block中使用全局变量
    weakSelf.string1 = @"3";
    NSString * (^block3)(NSString *) = ^(NSString *a)
    {
        weakSelf.string1 = [weakSelf.string1 stringByAppendingString:@"000"];
        NSLog(@"%@", weakSelf.string1);
        
        return weakSelf.string1;
    };
    
    NSLog(@"block3-> %@", block3);
    
    [self testBlock:block3];
    */
}

//3.作为参数传递的block
- (void)testBlock:(NSString *(^)(NSString *a))block
{
//    self.block1 = block;
    //    NSLog(@"block1-> %@", block1);
}

- (void)dealloc
{
    NSLog(@"ARC dealloc");
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
