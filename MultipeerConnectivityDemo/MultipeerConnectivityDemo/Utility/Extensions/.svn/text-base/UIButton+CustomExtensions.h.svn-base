//
//  UIButton+CustomExtensions.h
//  MOA
//
//  Created by Sea on 13-5-2.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (CustomExtensions)

/*!
 @function
 @abstract      创建UIButton的便捷方法
 
 @param         type:                   需要创建UIButton的样式
 @param         frame:                  相对于参数view的位置
 @param         view:                   该控件的父视图
 @param         imageName:              UIButton的图片  须有后缀名,如果没有,则默认png
                                        (1)nil,则无图片
                                        (2)根据值,找到图片,则为UIControlStateNormal状态下的图片
                                        (3)根据值,无法找到图片,则拼接_1,_2继续检测图片是否存在,如果存在,则xxx_1.png对应UIControlStateNormal,xxx_2.png对应UIControlStateHighlighted
                                        (4) 如果依旧不存在,则不设置图片
 @result        创建的UIButton实例
 */
+ (UIButton *)buttonWithType:(UIButtonType)type frame:(CGRect)frame targetView:(UIView *)view stateImageName:(NSString *)imageName imageBundle:(NSString *)bundle;




+ (UIButton *)buttonWithImageName:(NSString *)imageName backgroundImageName:(NSString *)backgroundImageName imageBundle:(NSString *)bundle;




- (void)buttonWithImageName:(NSString *)imageName imageBundle:(NSString *)bundleName;


- (void)buttonWithBackgroundImageName:(NSString *)backgroundImageName imageBundle:(NSString *)bundleName;

@end
