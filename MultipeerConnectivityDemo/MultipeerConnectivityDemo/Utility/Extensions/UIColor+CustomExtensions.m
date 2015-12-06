//
//  UIColor+CustomExtensions.m
//  Sandglass
//
//  Created by Sea on 13-11-8.
//
//

#import "UIColor+CustomExtensions.h"

@implementation UIColor (CustomExtensions)

+ (UIColor *)colorWithHex:(NSString *)hex
{
    unsigned int red = 0;
    unsigned int green = 0;
    unsigned int blue = 0;
    
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    
    range.location =0;
    
    [[NSScanner scannerWithString:[hex substringWithRange:range]]scanHexInt:&red];
    
    range.location =2;
    
    [[NSScanner scannerWithString:[hex substringWithRange:range]]scanHexInt:&green];
    
    range.location =4;
    
    [[NSScanner scannerWithString:[hex substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

@end
