//
//  ViewController.m
//  Test
//
//  Created by Kangqijun on 16/4/21.
//  Copyright © 2016年 Kangqijun. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"

@interface ViewController ()
{
    CAShapeLayer *masklayer;
    
    CGPoint sPoint;
    UIView *shadowView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *downImage = [UIImage imageNamed:@"black.png"];

    UIImageView *downImageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    downImageview.image = downImage;
    [self.view addSubview:downImageview];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 120, 120) cornerRadius:60];

    shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.layer.cornerRadius = 60;
    shadowView.center = self.view.center;
    [self.view addSubview:shadowView];
    
    shadowView.layer.shadowColor = [UIColor whiteColor].CGColor;//shadowColor阴影颜色
    shadowView.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    shadowView.layer.shadowOpacity = 0.6;//阴影透明度，默认0
    shadowView.layer.shadowRadius = 10;//阴影半径，默认3
    shadowView.layer.shadowPath = path.CGPath;//设置阴影路径
    
    UIImage *upImage = [UIImage imageNamed:@"color.png"];

    UIImageView *upImageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    upImageview.image = upImage;
    [self.view addSubview:upImageview];
    
    masklayer = [CAShapeLayer layer];
    masklayer.path = path.CGPath;
    masklayer.position = CGPointMake(self.view.center.x-60, self.view.center.y-60);
    upImageview.layer.mask = masklayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    sPoint = [[touches anyObject] locationInView:shadowView];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    CGRect rect = shadowView.frame;
    rect.origin.x = point.x - sPoint.x;
    rect.origin.y = point.y - sPoint.y;
    shadowView.frame = rect;
    
    masklayer.position = rect.origin;
    
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
