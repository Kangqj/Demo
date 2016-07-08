//
//  ViewController.m
//  PuzzleDemo
//
//  Created by coverme on 15/12/26.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [UIImage imageNamed:@"test.png"];
    [self.view addSubview:bgImageView];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view).width.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        
    }];
    
    [self addClock];
}

- (void)addClock
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    if (sysVersion>=8.0) {
        UIUserNotificationType type=UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        
        [[UIApplication sharedApplication]registerUserNotificationSettings:setting];
    }
    
    NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:10];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification != nil) {
        notification.fireDate = fireDate;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成
        //        notification.soundName = @"beep-beep.caf";
//        notification.alertLaunchImage = [NSString stringWithFormat:@"test.png"]; //闹钟的图片。
        notification.applicationIconBadgeNumber = 1; //闹钟的icon 数量。
        notification.repeatInterval = kCFCalendarUnitMinute;
        notification.alertBody = @"来消息啦！！！";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end