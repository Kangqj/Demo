//
//  ViewController.m
//  PuzzleDemo
//
//  Created by coverme on 15/12/26.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    
    来自：http://adad184.com/2014/09/28/use-masonry-to-quick-solve-autolayout/
    
    - (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *make))block;
    - (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *make))block;
    - (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block;
    
     mas_makeConstraints 只负责新增约束 Autolayout不能同时存在两条针对于同一对象的约束 否则会报错
     mas_updateConstraints 针对上面的情况 会更新在block中出现的约束 不会导致出现两个相同约束的情况
     mas_remakeConstraints 则会清除之前的所有约束 仅保留最新的约束
     
     三种函数善加利用 就可以应对各种情况了
     
     
     其次 equalTo 和 mas_equalTo的区别在哪里呢? 其实mas_equalTo是一个MACRO
     #define mas_equalTo(...)                 equalTo(MASBoxValue((__VA_ARGS__)))
     #define mas_greaterThanOrEqualTo(...)    greaterThanOrEqualTo(MASBoxValue((__VA_ARGS__)))
     #define mas_lessThanOrEqualTo(...)       lessThanOrEqualTo(MASBoxValue((__VA_ARGS__)))
     
     #define mas_offset(...)                  valueOffset(MASBoxValue((__VA_ARGS__)))
     可以看到 mas_equalTo只是对其参数进行了一个BOX操作(装箱) MASBoxValue的定义具体可以看看源代码 太长就不贴出来了
     
     所支持的类型 除了NSNumber支持的那些数值类型之外 就只支持CGPoint CGSize UIEdgeInsets
     */
    
    
    /*
     
     来自：http://www.cocoachina.com/ios/20150701/12217.html
     
     注意点1： 使用 mas_makeConstraints方法的元素必须事先添加到父元素的中，例如[self.view addSubview:view];
     
     注意点2： 
     masequalTo 和 equalTo 区别：
     mas_equalTo 比equalTo多了类型转换操作，一般来说，大多数时候两个方法都是 通用的，但是对于数值元素使用mas_equalTo。对于对象或是多个属性的处理，使用equalTo。特别是多个属性时，必须使用equalTo,例如 make.left.and.right.equalTo(self.view);
     
     注意点3: 注意到方法with和and,这连个方法其实没有做任何操作，方法只是返回对象本身，这这个方法的左右完全是为了方法写的时候的可读性 。make.left.and.right.equalTo(self.view);和make.left.right.equalTo(self.view);是完全一样的，但是明显的加了and方法的语句可读性 更好点。
     */
    
    WS(weakSelf)
    
    /********************************************/
    // 初始化view并设置背景
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    // 使用mas_makeConstraints添加约束
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加大小约束（make就是要添加约束的控件view）
        make.size.mas_equalTo(CGSizeMake(100, 100));
        // 添加居中约束（居中方式与self相同）
        make.center.equalTo(weakSelf.view); }];
    
    /********************************************/
    UIView *blackView = [UIView new];
    blackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackView];
    
    // 给黑色view添加约束
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 添加大小约束
        make.size.mas_equalTo(CGSizeMake(100, 100));
        
        // 添加左、上边距约束（左、上约束都是20）
        make.left.and.top.mas_equalTo(20);
    }];
    // 初始化灰色view
    UIView *grayView = [UIView new];
    grayView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:grayView];
    
    // 给灰色view添加约束
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 大小、上边距约束与黑色view相同
        make.size.and.top.equalTo(blackView);
        // 添加右边距约束（这里的间距是有方向性的，左、上边距约束为正数，右、下边距约束为负数）
        make.right.mas_equalTo(-20);
    }];
    
    
    UIView *blueView = [UIView new];
    blueView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueView];
    
    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.left.bottom.and.right.equalTo(view).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    /********************************************/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
