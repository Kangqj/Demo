//
//  ViewController.m
//  CategoryDemo
//
//  Created by 康起军 on 16/1/14.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //直角矩形
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(20, 30, 80, 50);
    [button1 setBackgroundImage:[UIImage drawRectImageWithColor:[UIColor randomColor] size:button1.frame.size] forState:UIControlStateNormal];
    [self.view addSubview:button1];
    
    //圆角矩形
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(20, 90, 80, 50);
    [button2 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor randomColor] size:button2.frame.size] forState:UIControlStateNormal];
    [self.view addSubview:button2];
    
    //圆形实心
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(20, 160, 80, 80);
    [button3 setBackgroundImage:[UIImage drawRoundImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:NO] forState:UIControlStateNormal];
    [self.view addSubview:button3];
    
    //圆形空心
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(20, 250, 80, 80);
    [button4 setBackgroundImage:[UIImage drawRoundImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button4];
    
    //三角形实心
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.frame = CGRectMake(20, 340, 80, 80);
    [button5 setBackgroundImage:[UIImage drawRadarBottomImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:NO] forState:UIControlStateNormal];
    [self.view addSubview:button5];
    
    //三角形空心
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6.frame = CGRectMake(20, 430, 80, 80);
    [button6 setBackgroundImage:[UIImage drawRadarBottomImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button6];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
