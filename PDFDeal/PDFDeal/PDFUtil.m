//
//  PDFUtil.m
//  PDFDeal
//
//  Created by Kangqijun on 16/7/6.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "PDFUtil.h"

@implementation PDFUtil

+ (void)insertImage:(NSString *)imagePath onPDF:(NSString *)pdfPath atPage:(int)page
{
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //创建CGPDFDocumentRef对象
    CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPath]);//沙盒中的文件路径
//    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)filename, NULL, NULL);//工程中的文件路径
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    
    //生成一个空的pdf上下文
    NSString *fileName = [NSString stringWithFormat:@"newPDF%d.pdf",arc4random_uniform(10000)];
    NSString *pdfPathOutput = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSLog(@"output path:%@", pdfPathOutput);
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    CGContextRef pdfContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    //设置页面参数
    CFMutableDictionaryRef pageDictionary = NULL;
    CFDataRef boxData = NULL;
    
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, 0);
    CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    
    pageDictionary = CFDictionaryCreateMutable(NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
    CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
    
    //绘制原pdf内容
    NSInteger numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
    for (int i=1; i<=numberOfPages; i++)
    {
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDocument, i);
        CGRect mediaBox = CGPDFPageGetBoxRect(pageRef, kCGPDFMediaBox);
        
        CGContextBeginPage(pdfContext, &mediaBox);
        CGContextDrawPDFPage(pdfContext, pageRef);
        
        //绘制图片
        if (i == page)
        {
            CGRect rect = CGRectMake(10, mediaBox.size.height - 10 - image.size.height, image.size.width, image.size.height);
            [self drawImage:pdfContext rect:rect image:image];
        }
        
        CGContextEndPage(pdfContext);
    }
    //结束绘制
    CGPDFContextClose(pdfContext);
    
    //释放变量
    CGContextRelease(pdfContext);
    CGPDFDocumentRelease(pdfDocument);
    CFRelease(pdfURL);
}

+ (void)drawImage:(CGContextRef)myContext rect:(CGRect)rect image:(UIImage *)image
{
    CFDataRef imgData = (__bridge CFDataRef)(UIImagePNGRepresentation(image));
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(imgData);
    CGImageRef imageRef = CGImageCreateWithPNGDataProvider(dataProvider,
                                                           NULL,
                                                           NO,
                                                           kCGRenderingIntentDefault);
    
    CGContextDrawImage(myContext, rect, imageRef);
    CGDataProviderRelease(dataProvider);
    CGImageRelease(imageRef);
}

@end
