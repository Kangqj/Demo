//
//  Utils.h
//  Rememberword
//
//  Created by kang on 13-11-25.
//  Copyright (c) 2013年 com.KQJ.house. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomNumber : NSObject

//从[from,to）中取随机数
+ (int)getRandomNumberBetween:(int)from to:(int)to;

//从[from,to）中取_count个不重复的随机数
+ (NSMutableArray *)getNoRepeatNumBetween:(int)from to:(int)to num:(int)_count;

//从[from,to]中取_count个不重复的随机数，除了number
+ (NSMutableArray *)getNoRepeatNumBetween:(int)from to:(int)to num:(int)_count except:(int)number;

@end
