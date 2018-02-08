//
//  AipGeneralVC.h
//  OCRLib
//
//  Created by Yan,Xiangda on 2017/2/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AipGeneralVC : UIViewController


@property (nonatomic, copy) void (^handler)(UIImage *image, AipGeneralVC *vc);

+(UIViewController *)ViewControllerWithHandler:(void (^)(UIImage *image, AipGeneralVC *vc))handler;

//设置页面为初始页面
- (void)reset;

@end
