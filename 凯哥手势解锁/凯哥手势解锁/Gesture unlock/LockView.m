//
//  LockView.m
//  新华易贷
//
//  Created by 吴 凯 on 15/9/21.
//  Copyright (c) 2015年 吴 凯. All rights reserved.
//

#import "LockView.h"
#define SteveZLineColor [UIColor colorWithRed:0.0 green:170/255.0 blue:255/255.0 alpha:1.0]

@interface LockView ()
// 保存所有的按钮
@property (nonatomic, strong) NSArray* buttons;
// 保存所有“碰过”的按钮
@property (nonatomic, strong) NSMutableArray* selectedButtons;

// 定义一个线的颜色
@property (nonatomic, strong) UIColor *lineColor;


// 记录最后用户触摸的点
@property (nonatomic, assign) CGPoint currentPoint;
@end
@implementation LockView

- (UIColor *)lineColor
{
    if (_lineColor == nil) {
        _lineColor = SteveZLineColor;
    }
    return _lineColor;
}

- (NSMutableArray*)selectedButtons
{
    if (_selectedButtons == nil) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

- (NSArray*)buttons
{
    if (_buttons == nil) {
        // 创建9个按钮
        NSMutableArray* arrayM = [NSMutableArray array];
        
        for (int i = 0; i < 9; i++) {
            UIButton *button=[[UIButton alloc]init];
            button.tag = i;
            
            button.userInteractionEnabled = NO;
            
            // 设置按钮的背景图片
            [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateDisabled];
            [self addSubview:button];
            [arrayM addObject:button];
        }
        _buttons = arrayM;
    }
    return _buttons;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置每个按钮的frame
    CGFloat w = 74;
    CGFloat h = 74;
    // 列（和行）的个数
    int columns = 3;
    // 计算水平方向和垂直方向的间距
    CGFloat marginX = (self.frame.size.width - columns * w) / (columns + 1);
    CGFloat marginY = (self.frame.size.height - columns * h) / (columns + 1);
    
    // 计算每个按钮的x 和 y
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = self.buttons[i];
        
        // 计算当前按钮所在的行号
        int row = i / columns;
        // 计算当前按钮所在的列索引
        int col = i % columns;
        
        CGFloat x = marginX + col * (w + marginX);
        CGFloat y = marginY + row * (h + marginY);
        
        button.frame = CGRectMake(x, y, w, h);
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // 1. 获取当前触摸的点
    UITouch* touch = touches.anyObject;
    CGPoint loc = [touch locationInView:touch.view];
    
    // 2. 循环判断当前触摸的点在哪个按钮的范围之内, 找到对一个的按钮之后, 把这个按钮的selected = YES
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = self.buttons[i];
        if (CGRectContainsPoint(button.frame, loc) && !button.selected) {
            button.selected = YES;
            [self.selectedButtons addObject:button];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // 1. 获取当前触摸的点
    UITouch* touch = touches.anyObject;
    CGPoint loc = [touch locationInView:touch.view];
    
    self.currentPoint = loc;
    
    // 2. 循环判断当前触摸的点在哪个按钮的范围之内, 找到对一个的按钮之后, 把这个按钮的selected = YES
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton* button = self.buttons[i];
        if (CGRectContainsPoint(button.frame, loc) && !button.selected) {
            button.selected = YES;
            [self.selectedButtons addObject:button];
            break;
        }
    }
    
    // 3. 重绘
    [self setNeedsDisplay];
}


// 手指抬起事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1. 获取用户绘制的密码
    NSMutableString *password = [NSMutableString string];
    for (UIButton *button in self.selectedButtons) {
        [password appendFormat:@"%@", @(button.tag)];
    }
    //获取本地的密码
   NSString *localpassone = [[NSUserDefaults standardUserDefaults]objectForKey:@"passwordone"];
    NSString *localpasstwo = [[NSUserDefaults standardUserDefaults]objectForKey:@"passwordtwo"];
    if (!localpassone||!localpasstwo) {
        if (!localpassone) {
            //保存用户绘制的密码
            [[NSUserDefaults standardUserDefaults]setObject:password forKey:@"passwordone"];
            if ([self.delegate respondsToSelector:@selector(setPassWordSuccess:)]) {
                [self.delegate setPassWordSuccess:@"再次输入新密码"];
            }
            [self clear];

        }else{
            //保存用户绘制的密码
            [[NSUserDefaults standardUserDefaults]setObject:password forKey:@"passwordtwo"];
            if ([self.delegate respondsToSelector:@selector(setPassWordSuccess:)]) {
                [self.delegate setPassWordSuccess:@"手势解锁"];
            }
            [self clear];
            [self confirmPassWord:password];


        }
            }else{
                [self confirmPassWord:password];

    
    }
    
    
    // 3. 根据控制器返回的密码判断结果, 执行不同的重绘操作
    
    
    
    
    //--------------------- 重绘 ---------------------------------
    
    
}

- (void)confirmPassWord:(NSString *)password{
    // 2. 通过代理, 把密码传递给控制器, 在控制器中判断密码是否正确
    if ([self.delegate respondsToSelector:@selector(unlockView:withPassword:)]) {
        // 判断密码是否正确
        if ([self.delegate unlockView:self withPassword:password]) {
            // 密码正确
            [self clear];
        } else {
            // 密码不正确
            // 1. 重绘成红色效果
            // 1.1 把selectedButtons中的每个按钮的selected = NO, enabled = NO
            for (UIButton *button in self.selectedButtons) {
                button.selected = NO;
                button.enabled = NO;
            }
            
            // 1.2 设置线段颜色为红色
            self.lineColor = [UIColor redColor];
            
            // 1.3 重绘
            [self setNeedsDisplay];
            
            
            // 禁用与用户的交互
            self.userInteractionEnabled = NO;
            
            
            // 2. 等待0.5秒中, 然后再清空
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self clear];
                self.userInteractionEnabled = YES;
            });
        }
    } else {
        [self clear];
    }
    
    
    




}

//重新设置密码的判断逻辑
- (void)resetPassWord{
    NSLog(@"kkkkk");

}

- (void)clear
{
    // 先将所有selectedButtons中的按钮的selected 设置为NO
    for (UIButton *button in self.selectedButtons) {
        button.selected = NO;
        button.enabled = YES;
    }
    self.lineColor = SteveZLineColor;
    
    // 移除所有的按钮
    [self.selectedButtons removeAllObjects];
    
    
    // 重绘
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //    if (self.selectedButtons.count > 0) {
    //        // 需要绘图
    //    }
    
    if (self.selectedButtons.count == 0) return;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // 循环获取每个按钮的中心点，然后连线
    for (int i = 0; i < self.selectedButtons.count; i++) {
        UIButton *button = self.selectedButtons[i];
        if (i == 0) {
            // 如果是第一个按钮, 那么就把这个按钮的中心点作为起点
            [path moveToPoint:button.center];
        } else {
            [path addLineToPoint:button.center];
        }
    }
    
    // 把最后手指的位置和最后一个按钮的中心点连起来
    [path addLineToPoint:self.currentPoint];
    
    // 设置线条颜色
    [self.lineColor set];
    
    
    // 渲染
    [path stroke];
    
}


@end
