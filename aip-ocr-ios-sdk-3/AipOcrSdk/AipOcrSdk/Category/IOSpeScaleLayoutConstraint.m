//
//  IOSpeScaleLayoutConstraint.m
//  OCRLib
//
//  Created by Yan,Xiangda on 2017/2/15.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "IOSpeScaleLayoutConstraint.h"

@implementation IOSpeScaleLayoutConstraint

- (void)awakeFromNib{
    
    [super awakeFromNib];
    CGFloat SpeScale = ([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1;
    self.constant = roundf(self.constant * SpeScale);
}


@end
