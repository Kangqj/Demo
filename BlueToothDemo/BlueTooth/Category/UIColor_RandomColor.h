//
//  UIColor_RandomColor.h
//  MultipeerConnectivityDemo
//
//  Created by Kangqj on 15/11/6.
//  Copyright (c) 2015年 Kangqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RandomColor)

+ (UIColor *)randomColor;
+ (CGFloat)redValueFrom:(UIColor *)color;
+ (CGFloat)greenValueFrom:(UIColor *)color;
+ (CGFloat)blueValueFrom:(UIColor *)color;
+ (UIColor*)colorWithHexString:(NSString *)stringToConvert;

@end

@implementation UIColor (RandomColor)

+ (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

+ (CGFloat)redValueFrom:(UIColor *)color
{
//    const CGFloat *components = CGColorGetComponents(color.CGColor);
//    CGFloat R = components[0];
//    return red;
    
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    CGFloat red = 0.0;
    if (RGBArr.count > 0)
    {
        red = [[RGBArr objectAtIndex:1] floatValue];
    }
    
    return red;
}

+ (CGFloat)greenValueFrom:(UIColor *)color
{
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取绿色值
    CGFloat green = 0.0;
    if (RGBArr.count > 1)
    {
        green = [[RGBArr objectAtIndex:2] floatValue];
    }
    
    
    return green;
    
//    const CGFloat *components = CGColorGetComponents(color.CGColor);
//    CGFloat R = components[1];
//    
//    return R;
}

+ (CGFloat)blueValueFrom:(UIColor *)color
{
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取蓝色值
    CGFloat blue = 0.0;
    
    if (RGBArr.count > 2)
    {
        blue = [[RGBArr objectAtIndex:2] floatValue];
    }
    
    return blue;
    
//    const CGFloat *components = CGColorGetComponents(color.CGColor);
//    CGFloat R = components[2];
//    
//    return R;
}

+ (UIColor*)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6 &&[cString length] != 8) return nil;
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b,a=255.0;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    if ([cString length] == 8)
    {
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
    }
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

//将UIColor转换为RGB值
+ (NSMutableArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    int r = [[RGBArr objectAtIndex:1] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    int g = [[RGBArr objectAtIndex:2] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    int b = [[RGBArr objectAtIndex:3] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}

@end
