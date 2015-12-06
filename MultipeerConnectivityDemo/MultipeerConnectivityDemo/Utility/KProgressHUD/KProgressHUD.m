//
//  KProgressHUD.m
//  CrazyRabbiter
//
//  Created by 康起军 on 14-10-20.
//  Copyright (c) 2014年 康起军. All rights reserved.
//

#import "KProgressHUD.h"

@implementation KProgressHUD

@synthesize HUDView;
@synthesize dTime;
@synthesize yoffset;

+ (KProgressHUD *)showHUDWithText:(NSString *)text height:(float)height
{
    KProgressHUD *HUD = [[KProgressHUD alloc] initWithText:text height:height];
    
    [HUD showAnimation];
    
    return HUD;
}


+ (KProgressHUD *)showHUDWithText:(NSString *)text delay:(float)time height:(float)height
{
    KProgressHUD *HUD = [[KProgressHUD alloc] initWithText:text height:height];
    HUD.dTime = time;
    
    [HUD showAnimation];
    
    return HUD;
}

- (id)initWithText:(NSString *)text height:(float)height
{
    self = [super init];
    if (self)
    {
        NSArray *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:HUDTextFont] constrainedToSize:CGSizeMake(300, 40)];
        
        HUDView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width+10, height)];
        HUDView.backgroundColor = [UIColor blackColor];
        HUDView.center = CGPointMake(kMainScreenWidth/2, HUDyOffset);
        HUDView.layer.cornerRadius = 8;
        HUDView.userInteractionEnabled = NO;
        [window.rootViewController.view addSubview:HUDView];
        HUDView.alpha = 0;
        
        HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
        HUDView.layer.shadowOffset = CGSizeMake(4, 4);
        HUDView.layer.shadowOpacity = 0.7;//阴影透明度，默认0
        HUDView.layer.shadowRadius = 4;
        
        UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, HUDView.frame.size.width, HUDView.frame.size.height)];
        textLab.text = text;
        textLab.font = [UIFont boldSystemFontOfSize:HUDTextFont];
        textLab.textColor = [UIColor whiteColor];
        textLab.backgroundColor = [UIColor clearColor];
        textLab.center = CGPointMake(HUDView.frame.size.width/2, HUDView.frame.size.height/2);
        textLab.textAlignment = UITextAlignmentCenter;
        textLab.numberOfLines = 0;
        [HUDView addSubview:textLab];
        
    }
    
    return self;
}

- (void)setYoffset:(float)yoffsets
{
    HUDView.center = CGPointMake(kMainScreenWidth/2, yoffsets);
}

- (void)showAnimation
{
    [UIView animateWithDuration:AnimatehDuration animations:^{
        
        HUDView.alpha = 0.7;
        
    } completion:^(BOOL finished) {
        
        float delayTime = self.dTime;
        
        if (delayTime == 0)
        {
            delayTime = HUDStayTime;
        }
        
        [self performSelector:@selector(dissmissHUD) withObject:nil afterDelay:delayTime];
        
    }];
}


- (void)dissmissHUD
{
    [UIView animateWithDuration:AnimatehDuration animations:^{
        
        HUDView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [HUDView removeFromSuperview];
        
    }];
}


@end
