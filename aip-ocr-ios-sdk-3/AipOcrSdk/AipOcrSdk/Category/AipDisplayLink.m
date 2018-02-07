//
//  AipDisplayLink.m
//  AipOcrSdk
//
//  Created by Yan,Xiangda on 2017/6/7.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "AipDisplayLink.h"

@interface  AipDisplayLink()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL stopped;

@end

@implementation AipDisplayLink

- (void)dealloc
{
    [self.displayLink invalidate];

}

+ (instancetype)displayLinkWithDelegate:(id<AipDisplayLinkDelegate>)delegate
{
    AipDisplayLink *displayLink = [[self alloc] init];
    displayLink.delegate = delegate;
    return displayLink;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.stopped = YES;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)start
{
    self.displayLink.paused = NO;

    self.stopped = NO;
}

//------------------------------------------------------------------------------

- (void)stop
{

    self.displayLink.paused = YES;

    self.stopped = YES;
}

//------------------------------------------------------------------------------

- (void)update
{
    if (!self.stopped)
    {
        if ([self.delegate respondsToSelector:@selector(displayLinkNeedsDisplay:)])
        {
            [self.delegate displayLinkNeedsDisplay:self];
        }
    }
}

@end
