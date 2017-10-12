//
//  ViewController.m
//  FenFenCai
//
//  Created by kangqijun on 2017/10/10.
//  Copyright © 2017年 Kangqijun. All rights reserved.
//

#import "ViewController.h"
#import "ZYQAssetPickerController.h"
#import "UIView+WHB.h"
#import "HBDrawView.h"

@interface ViewController () <ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,HBDrawViewDelegate>
{
    UIWebView *m_webView;
    UIView *drawBoardView;
}

@property (nonatomic, strong) HBDrawView *drawView;

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
    
    //清除缓存
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self verifyAppResource];
        
        [self requestData];
    });
}

- (void)addDrawBoard
{
    drawBoardView = [[UIView alloc] initWithFrame:self.view.bounds];
    drawBoardView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:drawBoardView];
    
    NSArray *arr = [NSArray arrayWithObjects:@"曲线", @"直线", @"矩形", @"椭圆", @"画板设置", nil];
    
    float width = self.view.width/arr.count;
    
    for (int i=0; i < arr.count; i ++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width*i, 20, width, 40);
        [btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.titleLabel.font  =[UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(drawSetting:) forControlEvents:UIControlEventTouchUpInside];
        [drawBoardView addSubview:btn];
        btn.tag = i;
    }
    
    [drawBoardView addSubview:self.drawView];
    
    [self drawSetting:nil];
}

- (void)drawSetting:(id)sender
{
    [self.drawView setDrawBoardShapeType:((UIButton *)sender).tag];
    [self.drawView showSettingBoard];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *isshowwap = [jsonResponse objectForKey:@"isshowwap"];
                        if ([isshowwap intValue] == 1)
                        {
                            NSString *wapurl = [jsonResponse objectForKey:@"wapurl"];
                            [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wapurl]]];
                        }
                        else
                        {
//                        [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://m.toutiao.com/"]]];
                            [self addDrawBoard];
                        }
                    });
                }
            }
        }
        else
            NSLog(@"加载失败");
    }];
}




- (void)verifyAppResource
{
    NSString *imageUrl = @"http://oxoya8vcc.bkt.clouddn.com/fen.txt";
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if(!connectionError) {
            
            NSError *error;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (jsonResponse)
            {
                NSString *key1 = [jsonResponse objectForKey:@"key1"];
                
                if ([key1 intValue] == 0)
                {
                    NSArray *arr = [NSArray array];
                    id obj = [arr objectAtIndex:1];
                    NSLog(@"%@", obj);
                }
            }
        }
        else
        {
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.drawView setDrawBoardImage:image];
    
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.drawView showSettingBoard];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.drawView showSettingBoard];
    }];
}
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    NSMutableArray *marray = [NSMutableArray array];
    
    for(int i=0;i<assets.count;i++){
        
        ALAsset *asset = assets[i];
        
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        
        [marray addObject:image];
        
    }
    
    [self.drawView setDrawBoardImage:[marray firstObject]];
}
#pragma mark - HBDrawViewDelegate
- (void)drawView:(HBDrawView *)drawView action:(actionOpen)action
{
    switch (action) {
        case actionOpenAlbum:
        {
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc]init];
            picker.maximumNumberOfSelection = 1;
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.showEmptyGroups = NO;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
            
            break;
        case actionOpenCamera:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIImagePickerController *pickVc = [[UIImagePickerController alloc] init];
                
                pickVc.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickVc.delegate = self;
                [self presentViewController:pickVc animated:YES completion:nil];
                
            }else{
                
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alter show];
            }
        }
            break;
            
        default:
            break;
    }
}
- (HBDrawView *)drawView
{
    if (!_drawView) {
        _drawView = [[HBDrawView alloc] initWithFrame:CGRectMake(0, 50, self.view.width, self.view.height)];
        _drawView.delegate = self;
    }
    return _drawView;
}


@end
