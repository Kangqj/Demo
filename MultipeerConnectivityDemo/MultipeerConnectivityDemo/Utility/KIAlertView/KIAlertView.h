//
//  KIAlertView.h
//  MOA
//
//  Created by kangqijun on 14-10-21.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

typedef void (^ ButtonChick)(NSInteger btnTag, NSString *fileName);
typedef void (^ ButtonEvent)(NSInteger);

@interface KIAlertView : UIView
{
    UIButton     *bgButton;
    UIView       *contentView;
    UILabel      *titleLab;
    UITextField  *textField;
    
    ButtonChick  buttonChick;
    ButtonEvent  buttonEvent;
}

@property (copy, nonatomic) ButtonChick  buttonChick;
@property (copy, nonatomic) ButtonEvent  buttonEvent;
@property (strong, nonatomic) UIView       *contentView;

#pragma -mark 标准alertView 双按钮+输入框方法
+ (KIAlertView *)showAlertViewWithView:(UIView *)mainView WithTitle:(NSString *)title withChickBlk:(ButtonChick)blk;

+ (KIAlertView *)showAlertInRootViewWithTitle:(NSString *)title withChickBlk:(ButtonChick)blk;

#pragma -mark 标准alertView 多按钮
+ (KIAlertView *)showAlertViewWithTiele:(NSString *)title message:(NSString *)msg buttonTitleArr:(NSArray *)arr event:(ButtonEvent)event;

- (id)initWithTitle:(NSString *)title message:(NSString *)msg buttonTitleArr:(NSArray *)arr event:(ButtonEvent)event;
- (void)show;

#pragma -mark 通用方法，自定义内容视图
+ (KIAlertView *)showAlertViewWithContentView:(UIView *)aContent;

- (void)dismissKIAlertView;

@end
