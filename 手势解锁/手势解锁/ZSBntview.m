//
//  ZSBntview.m
//  手势解锁
//
//  Created by Tony on 16/1/9.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ZSBntview.h"
@interface ZSBntview()
@property(nonatomic)NSMutableArray *bntarry;
@property(nonatomic)CGPoint currpoint;
@end
@implementation ZSBntview

//懒加载
-(NSMutableArray *)bntarry{
    if (_bntarry ==nil) {
        _bntarry = [NSMutableArray array];
    }
    return _bntarry;
}
-(void)awakeFromNib{
    //用循环创建按钮
    for (NSInteger i=0; i < 9; i++) {
        UIButton *button = [[UIButton alloc]init];
        //设置按钮默认图片
        [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        //设置按钮选中图片
        [button setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        //禁止交互
        button.userInteractionEnabled = NO;
        //给按钮一个 tag
        button.tag = i+1;
        //添加到view中
        [self addSubview:button];
    }
}

//设置按钮的 frame
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置按钮的宽
    CGFloat bntW = 75;
    //设置按钮的高
    CGFloat bntH = bntW;
    //设置父控件的宽
    CGFloat supW = self.frame.size.width;
    //设置父控件的高
    CGFloat supH = self.frame.size.height;

    //竖直两边的间隔
    CGFloat marginR = (supW - bntW *3)/4;
    //横向两边的间隔
    CGFloat marginC = (supH - bntH *3)/4;
    
    for (NSInteger i=0; i < 9; i++) {
        CGFloat bntX = marginR + (bntW + marginR) * (i / 3);
        CGFloat bntY = marginC + (bntH + marginC) * (i % 3);
        UIButton *bnt = [[UIButton alloc]init];
        bnt = self.subviews[i];
        bnt.frame = CGRectMake(bntX, bntY, bntW, bntH);
    }
    
}

//手指点击
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //获取触控对象
    UITouch *touch = [touches anyObject];
    //获取触控对象的点坐标
    CGPoint touchP = [touch locationInView:touch.view];
    //判断点坐标是否在按钮区域内
    for (NSInteger i=0; i < self.subviews.count; i++) {
        //获取按钮
        UIButton *bnt = self.subviews[i];
        //判断这点是否在按钮区域内
        if (CGRectContainsPoint(bnt.frame, touchP) && bnt.selected ==NO) {
            //如果是则为选中状态
            bnt.selected = YES;
            //把选中的按钮添加到数组中
            [self.bntarry addObject:bnt];
        }
    }
}

//手指移动
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //创建出最后一条没有连接的线路
    UITouch *touch = [touches anyObject];
    self.currpoint = [touch locationInView:touch.view];
    [self touchesBegan:touches withEvent:event];
    
    [self setNeedsDisplay];
}

//手指离开
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //把最后一个点的中心点赋值给属性记录的那个点
    self.currpoint = [[self.bntarry lastObject] center];
    //重绘
    [self setNeedsDisplay];
    //拼接字符
    NSMutableString *strM = [[NSMutableString alloc]init];
    for (NSInteger i=0; i < self.bntarry.count; i++) {
        UIButton *bnt = [[UIButton alloc]init];
        bnt = self.bntarry[i];
        //拼接
        [strM appendFormat:@"%@",@(bnt.tag)];
    }
    //实现代理
    if ([self.delegate respondsToSelector:@selector(zsbntview::)]) {
        [self.delegate zsbntview:self :strM];
    }
    //移除所有按钮的选中状态
    for (UIButton *bnt in self.bntarry) {
        bnt.selected = NO;
    }
    //移除数组里面的子控件
    [self.bntarry removeAllObjects];
    //重绘
    [self setNeedsDisplay];
    
   
//    NSLog(@"%@",strM);
}

- (void)drawRect:(CGRect)rect {
    //如果数组不为空就执行
    if (self.bntarry.count != 0) {
    //绘制路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    //设置线宽
    path.lineWidth = 5;
    //设置颜色
    [[UIColor yellowColor]set];
    //设置其实处样式
    path.lineCapStyle = kCGLineCapRound;
    //设置交点样式
    path.lineJoinStyle = kCGLineJoinRound;
    //设置起始点和线路
    for (NSInteger i=0; i < self.bntarry.count; i++) {
        UIButton * Bntcen = self.bntarry[i];
        CGPoint cen = Bntcen.center;
        if (i == 0 ) {
            [path moveToPoint:cen];
        }else{
            [path addLineToPoint:cen];
        }
        
    }
        //把最后一条线路添加进去
    [path addLineToPoint:self.currpoint];
    //绘制
    [path stroke];
    }
}


@end
