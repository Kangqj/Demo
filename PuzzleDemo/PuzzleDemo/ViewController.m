//
//  ViewController.m
//  PuzzleDemo
//
//  Created by coverme on 15/12/26.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [UIImage imageNamed:@"test.png"];
    [self.view addSubview:bgImageView];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view).width.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end