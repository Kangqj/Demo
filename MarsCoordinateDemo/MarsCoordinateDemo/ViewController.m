//
//  ViewController.m
//  MarsCoordinateDemo
//
//  Created by coverme on 16/1/30.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //WebAPI: http://lbsyun.baidu.com/index.php?title=webapi/guide/changeposition
    
    [self exchangeCoords:CLLocationCoordinate2DMake(118.781332,32.059105) isGPS:NO];
}

- (void)exchangeCoords:(CLLocationCoordinate2D)cll isGPS:(BOOL)isgps
{
    NSString *coords = [NSString stringWithFormat:@"%f,%f",cll.latitude, cll.longitude];
    NSString *ak = @"mEqVXQmbhj7RM8nPqvWFy3EC";
    NSString *from = @"3";
    if (isgps)
    {
        from = @"1";
    }
    NSString *to = @"5";
    NSString *mcode = @"sss.MarsCoordinateDemo";
    
    NSString *httpUrl = @"http://api.map.baidu.com/geoconv/v1/";
    NSString *httpArg = [NSString stringWithFormat:@"coords=%@&from=%@&to=%@&ak=%@&mcode=%@",coords, from, to, ak, mcode];
    
    [self request:httpUrl withHttpArg:httpArg];
}

#pragma mark 使用百度的WebAPI对非百度地图坐标的坐标转化为百度地图的坐标
-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg
{
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error)
                               {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               }
                               else
                               {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",responseString);
                                   
                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   NSLog(@"---%@",dic);
                                   
                                   NSString *status = [dic objectForKey:@"status"];
                                   
                                   if ([status intValue] == 0)
                                   {
                                       NSArray *arr = [dic objectForKey:@"result"];
                                       if (arr.count > 0)
                                       {
                                           NSDictionary *dic = [arr objectAtIndex:0];
                                           
                                           NSLog(@"\n转换成功-转换结果:%@",dic);
                                       }
                                       
                                   }

                               }
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
