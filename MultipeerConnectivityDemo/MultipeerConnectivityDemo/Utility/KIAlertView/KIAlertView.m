//
//  KIAlertView.m
//  MOA
//
//  Created by kangqijun on 14-10-21.
//
//

#import "KIAlertView.h"

@implementation KIAlertView

static char overviewKey;

@synthesize buttonChick, contentView, buttonEvent;

#pragma -mark 通用方法，自定义内容视图

+ (KIAlertView *)showAlertViewWithContentView:(UIView *)aContent
{
    KIAlertView *myAlertView = [[KIAlertView alloc] init];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    aContent.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    aContent.layer.cornerRadius = 8;
    aContent.alpha = 0;
    aContent.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
    
    myAlertView.contentView = aContent;
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    [window.rootViewController.view addSubview:myAlertView.contentView];
    
    [myAlertView showAnimation];
    
    return myAlertView;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        NSArray *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bgButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        bgButton.backgroundColor = [UIColor blackColor];
        [bgButton addTarget:self action:@selector(returnKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [window.rootViewController.view addSubview:bgButton];
        bgButton.alpha = 0;
    }
    
    return self;
}

- (void)dismissKIAlertView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        bgButton.alpha = 0;
        contentView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [bgButton removeFromSuperview];
        [contentView removeFromSuperview];
    }];
}

- (void)showAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        
        bgButton.alpha = 0.6;
        
    } completion:^(BOOL finished) {
        
        NSArray *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        UIView *mainView = window.rootViewController.view;
        [mainView addSubview:self];
        
        contentView.alpha = 1;
        [self exChangeOut:contentView dur:0.3];
        
    }];
}

-(void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = dur;
    
    //animation.delegate = self;
    
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [changeOutView.layer addAnimation:animation forKey:nil];
    
}

#pragma -mark 标准alertView 多按钮

+(KIAlertView *)showAlertViewWithTiele:(NSString *)title message:(NSString *)msg buttonTitleArr:(NSArray *)arr event:(ButtonEvent)event
{
    KIAlertView *myAlertView = [[KIAlertView alloc] initWithTitle:title message:msg buttonTitleArr:arr event:event];
//    myAlertView.buttonEvent = event;
    [myAlertView showAnimation];
    
    return myAlertView;
}


- (id)initWithTitle:(NSString *)title message:(NSString *)msg buttonTitleArr:(NSArray *)arr event:(ButtonEvent)event
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        // Initialization code
        
        objc_setAssociatedObject(self, &overviewKey, event, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        self.backgroundColor = [UIColor clearColor];
        
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bgButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        bgButton.backgroundColor = [UIColor blackColor];
        [self addSubview:bgButton];
        bgButton.alpha = 0;
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
        contentView.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        [self addSubview:contentView];
        contentView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        contentView.layer.cornerRadius = 8;
        contentView.alpha = 0;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentView.frame.size.width-70, 15, 50, 50)];
        imageView.image = [UIImage imageNamed:@"success.png"];
        [contentView addSubview:imageView];
        
        NSRange range = [title rangeOfString:@"成功"];
        
        if (range.location == NSNotFound)
        {
            imageView.image = [UIImage imageNamed:@"fail.png"];
        }
        
        titleLab  = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, contentView.frame.size.width, 40)];
        titleLab.font = [UIFont boldSystemFontOfSize:20];
        [titleLab setTextColor:[UIColor blackColor]];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.text = title;
        [titleLab setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:titleLab];
        
        if (msg != nil)
        {
            UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, contentView.frame.size.width, 40)];
            messageLab.textAlignment = NSTextAlignmentCenter;
            messageLab.textColor = [UIColor blackColor];
            messageLab.font = [UIFont boldSystemFontOfSize:14];
            messageLab.text = msg;
            messageLab.backgroundColor = [UIColor clearColor];
            [contentView addSubview:messageLab];
        }
        else
        {
            titleLab.frame  = CGRectMake(0, 30, contentView.frame.size.width, 40);
        }
        
        if ([arr count] == 1)
        {
            
        }
        else if ([arr count] == 2)
        {
            UIView *lineViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 89, contentView.frame.size.width, 0.8)];
            lineViewOne.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:lineViewOne];
            
            UIView *lineViewTwo = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2, 89, 0.8, 45)];
            lineViewTwo.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:lineViewTwo];
            
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelBtn.frame = CGRectMake(0, 90, contentView.frame.size.width/2, 45);
            [cancelBtn setTitle:[arr objectAtIndex:0] forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:97/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
            [cancelBtn addTarget:self action:@selector(alertButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
            cancelBtn.tag = 0;
            [contentView addSubview:cancelBtn];
            
            UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sureBtn.frame = CGRectMake(contentView.frame.size.width/2, 90, contentView.frame.size.width/2, 45);
            [sureBtn setTitle:[arr objectAtIndex:1] forState:UIControlStateNormal];
            [sureBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:97/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
            [sureBtn addTarget:self action:@selector(alertButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
            sureBtn.tag = 1;
            [contentView addSubview:sureBtn];
            
            CGRect rect = contentView.frame;
            rect.size.height = 135;
            contentView.frame = rect;

        }
        else if ([arr count] > 2)
        {
            for (int i = 0; i < [arr count]; i ++)
            {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 90 + 45 * i, contentView.frame.size.width, 45);
                [button setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor colorWithRed:0/255.0 green:97/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(alertButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                [contentView addSubview:button];
                
                UIView *lineViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 0.8)];
                lineViewOne.backgroundColor = [UIColor lightGrayColor];
                [button addSubview:lineViewOne];
            }
        }
    }
    
    return self;
}


- (void)alertButtonEvent:(UIButton *)button
{
    if (button.tag != 1)
    {
        [self dissmiss];
    }
    
    ButtonEvent event = (ButtonEvent)objc_getAssociatedObject(self, &overviewKey);
    event(button.tag);
}

- (void)show
{
    [UIView animateWithDuration:0.3 animations:^{
        
        bgButton.alpha = 0.6;
        contentView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        NSArray *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        UIView *mainView = window.rootViewController.view;
        [mainView addSubview:self];
        
        [self exChangeOut:contentView dur:0.3];
        
    }];
}

- (void)dissmiss
{
    [UIView animateWithDuration:0.5 animations:^{
        
        contentView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [bgButton removeFromSuperview];
        [contentView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma -mark 标准alertView 双按钮+输入框方法

+ (KIAlertView *)showAlertViewWithView:(UIView *)mainView WithTitle:(NSString *)title withChickBlk:(ButtonChick)blk
{
    KIAlertView *myAlertView = [[KIAlertView alloc] initWithTitle:title withView:mainView];
    [myAlertView showAnimation];
    
    myAlertView.buttonChick = blk;
    
    return myAlertView;
}

+ (KIAlertView *)showAlertInRootViewWithTitle:(NSString *)title withChickBlk:(ButtonChick)blk
{
    KIAlertView *myAlertView = [[KIAlertView alloc] initWithTitle:title withView:nil];
    [myAlertView showAnimation];
    
    myAlertView.buttonChick = blk;
    
    return myAlertView;
}

- (id)initWithTitle:(NSString *)title withView:(UIView *)mainView
{
    self = [super init];
    if (self) {
        // Initialization code
        
        if (mainView == nil)
        {
            NSArray *windows = [UIApplication sharedApplication].windows;
            UIWindow *window = [windows objectAtIndex:0];
            
            mainView = window.rootViewController.view;
        }
        
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        
        bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bgButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        bgButton.backgroundColor = [UIColor blackColor];
        [bgButton addTarget:self action:@selector(returnKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:bgButton];
        bgButton.alpha = 0;
        
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 271, 135)];
        contentView.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        [mainView addSubview:contentView];
        contentView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        contentView.layer.cornerRadius = 8;
        contentView.alpha = 0;
        
        titleLab  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 271, 40)];
        titleLab.font = [UIFont boldSystemFontOfSize:16];
        [titleLab setTextColor:[UIColor blackColor]];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.text = title;
        [titleLab setTextAlignment:UITextAlignmentCenter];
        [contentView addSubview:titleLab];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 40, 230, 30)];
        textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField.layer.borderWidth = 1.0;
        [contentView addSubview:textField];
        
        UIView *lineViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 89, 271, 1)];
        lineViewOne.backgroundColor = [UIColor lightGrayColor];
        [contentView addSubview:lineViewOne];
        
        UIView *lineViewTwo = [[UIView alloc] initWithFrame:CGRectMake(136, 89, 1, 45)];
        lineViewTwo.backgroundColor = [UIColor lightGrayColor];
        [contentView addSubview:lineViewTwo];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 90, 135, 45);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:97/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = 0;
        [contentView addSubview:cancelBtn];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(136, 90, 135, 45);
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:97/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.tag = 1;
        [contentView addSubview:sureBtn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyboardWillShow
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = contentView.frame;
        rect.origin.y = rect.origin.y - 60;
        contentView.frame = rect;
        
    }];
}

- (void)keyboardWillHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = contentView.frame;
        rect.origin.y = rect.origin.y + 60;
        contentView.frame = rect;
        
    }];
}

- (void)returnKeyboard
{
    if ([textField becomeFirstResponder])
    {
        [textField resignFirstResponder];
    }
}

- (void)buttonAction:(UIButton *)btn
{
    if (textField)
    {
        [textField resignFirstResponder];
    }
    
    [self hiddenAnimation];
    
    self.buttonChick(btn.tag, textField.text);
}

- (void)hiddenAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        
        bgButton.alpha = 0;
        contentView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [bgButton removeFromSuperview];
        [contentView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
    }];
}

@end
