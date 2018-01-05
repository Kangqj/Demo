//
//  NSString+QDTouchID.m
//  Ewallet
//
//  Created by 陈博文 on 16/10/25.
//  Copyright © 2016年 UCSMY. All rights reserved.
//

#import "NSString+QDTouchID.h"
#include <sys/sysctl.h>
#import <UIKit/UIDevice.h>

#define IOS8_OR_LATER    ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define IS_Phone UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone

@implementation NSString (QDTouchID)

//是否是iOS8.0以上的系统

//是否是5s以上的设备支持
+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

// 判断是否支持TouchID,只判断手机端，ipad端我们不支持

+ (BOOL)judueIPhonePlatformSupportTouchID
{
    /*
     if ([platform isEqualToString:@"iPhone1,1"])   return @"iPhone1G GSM";
     if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone3G GSM";
     if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone3GS GSM";
     if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone4 GSM";
     if ([platform isEqualToString:@"iPhone3,3"])   return @"iPhone4 CDMA";
     if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone4S";
     if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone5";
     if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone5";
     if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c (A1456/A1532)";
     if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c (A1507/A1516/A1526/A1529)";
     if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s (A1453/A1533)";
     if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s (A1457/A1518/A1528/A1530)";
     */
    
    
    if(IS_Phone)
    {
        if([self platform].length > 6 )
        {
            
            NSString * numberPlatformStr = [[self platform] substringWithRange:NSMakeRange(6, 1)];
            NSInteger numberPlatform = [numberPlatformStr integerValue];
            // 是否是5s以上的设备
            if(numberPlatform > 5)
            {
                return YES;
            }
            else
            {
                return NO;
            }
            
        }
        else
        {
            return NO;
        }
    }
    else
    {
        // 我们不支持iPad 设备
        return NO;
    }

}

@end
