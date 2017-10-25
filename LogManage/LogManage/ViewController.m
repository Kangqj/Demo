//
//  ViewController.m
//  LogManage
//
//  Created by kangqijun on 2017/10/19.
//  Copyright © 2017年 Kangqijun. All rights reserved.
//

#import "ViewController.h"

#define NSLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

//#ifdef DEBUG
//#define HYLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#else
//#define HYLog(...)
//#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"test");
    
    //将log日志保存到文件
//#ifdef  BH_DEBUG
//    [self redirectNSLogToDocumentFolder];
//#else
//    
//#endif
    
    [self redirectNSLogToDocumentFolder];
    
    UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [continueBtn setFrame:CGRectMake(0, 50, 100, 44)];
    [continueBtn setTitle:@"Continue" forState:UIControlStateNormal];
    continueBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [continueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueBtn addTarget:self action:@selector(ContinueAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueBtn];
}

- (void)ContinueAction
{
    //把错误日志发送到邮箱
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSLog(@"%@", logDirectory);
    
    NSLog(@"-----1");
    NSArray *arr = [NSArray array];
    [arr objectAtIndex:0];
    NSLog(@"-----2");
    
//    NSString *urlStr = [NSString stringWithFormat:@"mailto://test@163.com?subject=bug报告&body=感谢您的配合!<br><br><br>错误详情:<br>%@",crashString];
//    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:url];
}

- (void)redirectNSLogToDocumentFolder
{
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        
        NSLog(@"xcode test");

        return;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    //在模拟器不保存到文件中
    if([[device model] hasSuffix:@"Simulator"]){
        
        NSLog(@"Simulator test");

        return;
    }
    
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    //将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

void UncaughtExceptionHandler(NSException* exception)
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ];
    //异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ];
    //将调用栈拼成输出日志的字符串
    for ( NSString* item in symbols )
    {
        [strSymbols appendString: item ];
        [strSymbols appendString: @"\r\n" ];
    }
    
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
