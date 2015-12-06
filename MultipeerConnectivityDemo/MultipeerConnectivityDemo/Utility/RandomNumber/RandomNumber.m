//
//  Utils.m
//  Rememberword
//
//  Created by kang on 13-11-25.
//  Copyright (c) 2013年 com.KQJ.house. All rights reserved.
//

#import "RandomNumber.h"

@implementation RandomNumber

//从[from,to）中取随机数
+ (int)getRandomNumberBetween:(int)from to:(int)to //[from,to]
{
    return (int)from + arc4random() % (to - from + 1);
}

//从[from,to]中取_count个不重复的随机数
+ (NSMutableArray *)getNoRepeatNumBetween:(int)from to:(int)to num:(int)_count
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (int i=0; i<_count; i++)
    {
        int random = [self getRandomNumberBetween:from to:to];
        NSString *num = [NSString stringWithFormat:@"%d",random];
        
        if (![arr containsObject:num])
        {
            [arr addObject:num];
        }
        else
        {
            i--;
        }
    }
    
    return arr;
}

//从[from,to]中取_count个不重复的随机数，除了number
+ (NSMutableArray *)getNoRepeatNumBetween:(int)from to:(int)to num:(int)_count except:(int)number
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (int i=0; i<_count; i++)
    {
        int random = [self getRandomNumberBetween:from to:to];
        NSString *num = [NSString stringWithFormat:@"%d",random];
        
        if (![arr containsObject:num] && ([num intValue] != number))
        {
            [arr addObject:num];
        }
        else
        {
            i--;
        }
    }
    
    return arr;
}

@end
