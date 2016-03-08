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
    [button5 setBackgroundImage:[UIImage drawTriangleImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:NO] forState:UIControlStateNormal];
    [self.view addSubview:button5];
    
    //三角形空心
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6.frame = CGRectMake(20, 430, 80, 80);
    [button6 setBackgroundImage:[UIImage drawTriangleImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button6];
    
    //笑脸
    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
    button7.frame = CGRectMake(150, 30, 80, 80);
    [button7 setBackgroundImage:[UIImage drawSmileFaceImageWithColor:[UIColor randomColor] size:button7.frame.size radius:80/3] forState:UIControlStateNormal];
    [self.view addSubview:button7];
    
    //椭圆空心
    UIButton *button8 = [UIButton buttonWithType:UIButtonTypeCustom];
    button8.frame = CGRectMake(150, 120, 100, 50);
    [button8 setBackgroundImage:[UIImage drawEllipseImageWithColor:[UIColor randomColor] size:button8.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button8];
    
    //椭圆实心
    UIButton *button9 = [UIButton buttonWithType:UIButtonTypeCustom];
    button9.frame = CGRectMake(150, 180, 100, 50);
    [button9 setBackgroundImage:[UIImage drawEllipseImageWithColor:[UIColor randomColor] size:button9.frame.size isEmpty:NO] forState:UIControlStateNormal];
    [self.view addSubview:button9];
    
    //贝塞尔曲线空心
    UIButton *button10 = [UIButton buttonWithType:UIButtonTypeCustom];
    button10.frame = CGRectMake(150, 240, 100, 50);
    [button10 setBackgroundImage:[UIImage drawBezierLineImageWithColor:[UIColor randomColor] size:button10.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button10];
    
    //贝塞尔曲线实心
    UIButton *button11 = [UIButton buttonWithType:UIButtonTypeCustom];
    button11.frame = CGRectMake(150, 300, 100, 50);
    [button11 setBackgroundImage:[UIImage drawBezierLineImageWithColor:[UIColor randomColor] size:button10.frame.size isEmpty:NO] forState:UIControlStateNormal];
    [self.view addSubview:button11];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
