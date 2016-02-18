>前段时间项目中遇到了一个问题：要上传当前位置的经纬度坐标到服务器
- Android使用百度地图获取；
- iOS使用GPS或系统自带的高德地图获取；

***
那么问题出现了：两种设备获取的经纬度有偏差。


![](http://gs.sysu.edu.cn/geoscience2008/content/chapter09/images/mars.jpg)

#解决方法：
以百度坐标为标准，使用百度提供的WebAPI来将非百度地图坐标转化为百度地图的坐标。

[WebAPI说明链接](http://lbsyun.baidu.com/index.php?title=webapi/guide/changeposition)

在使用该API的过程中，遇到了几个坑，需要说明一下：

| 坐标类型    | from参数   | to参数    |  mcode参数    | ak|
| :-------: | :----:| :-----: | :-----: |
| 高德地图坐标         | 3   | 5      |   Bundle Identifier  |  开发者密钥 |
| GPS坐标         | 1   | 5      |   Bundle Identifier  |  开发者密钥 |

>说明：
- mcode：为在百度开发者中心创建应用时，填写的安全码，一般为应用的Bundle Identifier;
- ak：创建应用完成后获得。


```

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

```

- 备注：国外用户不存在火星坐标的问题，所以不用处理

***
Demo下载链接：[MarsCoordinateDemo](https://github.com/Kangqj/Demo/tree/master/MarsCoordinateDemo)