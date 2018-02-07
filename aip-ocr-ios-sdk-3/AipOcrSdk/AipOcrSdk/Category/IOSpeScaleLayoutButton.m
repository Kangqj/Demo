//
//  IOSpeScaleLayoutButton.m
//  AipOcrSdk
//
//  Created by Yan,Xiangda on 2017/2/22.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "IOSpeScaleLayoutButton.h"

@implementation IOSpeScaleLayoutButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        CGFloat SpeScale = ([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1;
        
        UIFontDescriptor *fontDescriptor =[self.titleLabel.font fontDescriptor];
        UIFont *font = [UIFont fontWithName:fontDescriptor.postscriptName size:fontDescriptor.pointSize * SpeScale];
        self.titleLabel.font = font;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsMake(-20, -20, -20, -20), UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, UIEdgeInsetsMake(-20, -20, -20, -20));
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
