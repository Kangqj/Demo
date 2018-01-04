//
//  ZSBntview.h
//  手势解锁
//
//  Created by Tony on 16/1/9.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSBntview;
//设置代理
@protocol ZSBntviewDelegate <NSObject>

-(void)zsbntview:(ZSBntview *)bntview :(NSString *)strM;

@end
@interface ZSBntview : UIView
@property(nonatomic)id<ZSBntviewDelegate> delegate;
@end
