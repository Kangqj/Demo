//
//  LockView.h
//  新华易贷
//
//  Created by 吴 凯 on 15/9/21.
//  Copyright (c) 2015年 吴 凯. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, passwordtype){
    ResetPassWordType = 1,
    UsePassWordType = 2,
};
@class LockView;
@protocol LockViewDelegate <NSObject>

- (BOOL)unlockView:(LockView *)unlockView withPassword:(NSString *)password;

- (void)setPassWordSuccess:(NSString *)tabelname;
@end

@interface LockView : UIView
@property (nonatomic, weak) id<LockViewDelegate> delegate;
@end
