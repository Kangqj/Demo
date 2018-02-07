//
//  AipDisplayLink.h
//  AipOcrSdk
//
//  Created by Yan,Xiangda on 2017/6/7.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class AipDisplayLink;

@protocol AipDisplayLinkDelegate <NSObject>

@required

- (void)displayLinkNeedsDisplay:(AipDisplayLink *)displayLink;

@end

@interface AipDisplayLink : NSObject


+ (instancetype)displayLinkWithDelegate:(id<AipDisplayLinkDelegate>)delegate;


@property (nonatomic, weak) id<AipDisplayLinkDelegate> delegate;


- (void)start;

- (void)stop;

@end
