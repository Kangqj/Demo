//
//  ViewController.m
//  BlockDemo
//
//  Created by Kangqijun on 16/5/4.
//  Copyright © 2016年 Kangqijun. All rights reserved.
//

#import "ViewController.h"

//1.全局block
typedef NSString * (^ Block1)(NSString *a);

@interface ViewController ()
{
    Block1 block1;
    
    NSString *string1;
}

@property (copy, nonatomic) Block1 block1;
@property (strong, nonatomic) NSString *string1;

@end

@implementation ViewController

@synthesize block1,string1;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //2.局部block
    NSString * (^block2)(NSString *) = ^(NSString *a)
    {
        return [a stringByAppendingString:@"000"];
    };
    
    NSLog(@"%@", block2);
    
    //传入局部变量－传值进去
    NSString *string = @"2";
    block2(string);
    NSLog(@"%@", block2);
    
    string1 = @"3";
    void (^block4)() = ^{
        
        NSString *s = [string1 stringByAppendingString:@"000"];
        NSLog(@"%@", s);
    };
    
    NSLog(@"%@", block4);
    
    block4();
    
    void (^block5)() = ^{
        
        NSString *s = [self.string1 stringByAppendingString:@"000"];
        NSLog(@"%@", s);
    };
    
    NSLog(@"%@", block5);
    
    block5();

    [self testBlock:block2];
}

//3.作为参数传递的block
- (void)testBlock:(NSString *(^)(NSString *a))block3
{
    NSLog(@"%@", block1);
    NSLog(@"%@", block3);
    
    self.block1 = block3;
    
    NSLog(@"%@", block1);
    NSLog(@"%@", self.block1);
    NSLog(@"%@", block3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
