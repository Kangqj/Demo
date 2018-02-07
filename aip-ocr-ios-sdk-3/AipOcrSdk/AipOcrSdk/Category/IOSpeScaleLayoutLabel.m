//
//  IOSpeScaleLayoutLabel.m
//  OCRLib
//
//  Created by Yan,Xiangda on 2017/2/15.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "IOSpeScaleLayoutLabel.h"

@implementation IOSpeScaleLayoutLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        CGFloat SpeScale = ([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1;
        UIFontDescriptor *fontDescriptor =[self.font fontDescriptor];
        UIFont *font = [UIFont fontWithName:fontDescriptor.postscriptName size:fontDescriptor.pointSize * SpeScale];
        self.font = font;
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
