//
//  ViewController.m
//  手势解锁
//
//  Created by Tony on 16/1/9.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import "ZSBntview.h"
@interface ViewController ()<ZSBntviewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet ZSBntview *bntview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
    self.bntview.delegate = self;
}

//实现代理方法
-(void)zsbntview:(ZSBntview *)bntview :(NSString *)strM{
    //开启一个图形上下文
    UIGraphicsBeginImageContextWithOptions(bntview.frame.size, NO, 0.0);
    //获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //截图
    [self.bntview.layer renderInContext:ctx];
    //获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    //把获取的图片保存到 imageview 中
    self.imageview.image = image;
}
//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
