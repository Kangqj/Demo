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
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(20, 30, 80, 30);
    [button1 setBackgroundImage:[UIImage drawRectImageWithColor:[UIColor randomColor] size:button1.frame.size] forState:UIControlStateNormal];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(20, 80, 80, 30);
    [button2 setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor randomColor] size:button2.frame.size] forState:UIControlStateNormal];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(20, 130, 50, 50);
    [button3 setBackgroundImage:[UIImage drawRoundImageWithColor:[UIColor randomColor] size:button3.frame.size] forState:UIControlStateNormal];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(20, 200, 50, 50);
    [button4 setBackgroundImage:[UIImage drawRadarBottomImageWithColor:[UIColor randomColor] size:button3.frame.size isEmpty:YES] forState:UIControlStateNormal];
    [self.view addSubview:button4];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
