//
//  ViewController.m
//  SDWebImageTest
//
//  Created by 康起军 on 16/10/1.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

#define kImageURLString @"http://image8.360doc.com/DownloadImg/2010/04/0412/2762690_39.jpg"

/*
 - SDWebImage它可以判断图片的类型
 + 图片的十六进制数据, 的前8个字节都是一样的, 所以可以同判断十六进制来判断图片的类型
 + PNG
 + JPG
 + ...
 */

static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 400)];
    [self.view addSubview:imageView];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:kImageURLString] placeholderImage:nil options:SDWebImageTransformAnimatedImage];
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kImageURLString]];
    NSData *pngData = [NSData dataWithBytes:kPNGSignatureBytes length:8];
    BOOL isPNG = [[imageData subdataWithRange:NSMakeRange(0, 8)] isEqualToData:pngData];
    
    NSLog(@"%d", isPNG);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
