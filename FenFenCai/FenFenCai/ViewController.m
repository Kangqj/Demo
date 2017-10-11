//
//  ViewController.m
//  FenFenCai
//
//  Created by kangqijun on 2017/10/10.
//  Copyright © 2017年 Kangqijun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIWebView *m_webView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
     服务商请求接 口
     
     接口地址：
     http://www.27305.com/frontApi/getAboutUs?appid=（appid）
     
     (调用API时，可采取不在主函数中调用接口，在后台线程调用，以此来隐藏接口)
     
     参数类型：GET
     
     参数说明：接入者ID (710090007
     )
     
     返回值参数说明：
     1. isshowwap 是否跳转到wap页面，1：是 加载wapurl 2： 否  不加载wapurl,
     2. wapurl     wap页面URL，
     3. status 是否成功获取数据状态，1：成功，2：失败

     */
    
    m_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:m_webView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self requestData];
    });
    
}

- (void)requestData
{
    NSString *imageUrl = @"http://www.27305.com/frontApi/getAboutUs?appid=710090007";
    NSURL *url = [NSURL URLWithString:imageUrl];
    //3 定义NSURLRequest 对象
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    //4 发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if(!connectionError){
            
            NSLog(@"加载成功");
            
            NSError *error;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (jsonResponse)
            {
                /*
                 Printing description of jsonResponse:
                 {
                 appid = 710090007;
                 appname = "\U5206\U5206\U5f69iOS";
                 desc = "\U6210\U529f\U8fd4\U56de\U6570\U636e";
                 isshowwap = 2;
                 status = 1;
                 wapurl = "";
                 }
                 */
                
                NSLog(@"%@", jsonResponse);
                NSString *status = [jsonResponse objectForKey:@"status"];
                
                if ([status intValue] == 1)
                {
                    NSString *isshowwap = [jsonResponse objectForKey:@"isshowwap"];
                    if ([isshowwap intValue] == 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            NSString *wapurl = [jsonResponse objectForKey:@"wapurl"];
                            [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wapurl]]];
                            
                        });
                    }
                    else
                    {
                        [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.toutiao.com/"]]];
                    }
                }
            }
        }
        else
            NSLog(@"加载失败");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
