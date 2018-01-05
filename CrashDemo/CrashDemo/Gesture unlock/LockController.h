//
//  LockController.h
//  新华易贷
//
//  Created by 吴 凯 on 15/9/21.
//  Copyright (c) 2015年 吴 凯. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LockControllerDelegate <NSObject>

@optional
- (void)setGesturePasswordSuccess;

@end

@interface LockController : UIViewController

@property (assign, nonatomic) id <LockControllerDelegate> m_delegate;

@end
