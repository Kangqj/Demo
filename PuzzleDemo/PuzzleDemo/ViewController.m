//
//  ViewController.m
//  PuzzleDemo
//
//  Created by coverme on 15/12/26.
//  Copyright © 2015年 Kangqj. All rights reserved.
//

#import "ViewController.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebUploader.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface ViewController () <GCDWebUploaderDelegate>
{
    UIImageView *bgImageView;
    GCDWebServer* _webServer;
    GCDWebUploader* _webUploader;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 200)];
//    bgImageView.image = [UIImage imageNamed:@"test.jpg"];
//    [self.view addSubview:bgImageView];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(50,240,50,40);
    [btn1 addTarget:self action:@selector(startUploadServer) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitle:@"上传" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(120,240,50,40);
    [btn2 addTarget:self action:@selector(startDownLoadServer) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitle:@"下载" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
}

- (void)startDownLoadServer
{
    // Create server
    _webServer = [[GCDWebServer alloc] init];
    // Add a handler to respond to GET requests on any URL
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  
                                  return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                                  
                              }];
    
    // Start server on port 8080
    [_webServer startWithPort:8080 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}

- (void)startUploadServer
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsPath, @"test.jpg"];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:path error:NULL];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"];
    path = [NSString stringWithFormat:@"%@/%@", documentsPath, @"test1.jpg"];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:path error:NULL];

    _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    _webUploader.allowHiddenItems = YES;
    _webServer.delegate = self;
    [_webUploader start];
    NSLog(@"Visit %@ in your web browser", _webUploader.serverURL);
}

- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
