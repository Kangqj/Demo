//
//  PDFUtil.m
//  PDFDeal
//
//  Created by Kangqijun on 16/7/6.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "PDFUtil.h"

@implementation PDFUtil

+ (void)insertImage:(NSString *)imagePath onPDF:(NSString *)pdfPath atPage:(int)page position:(CGPoint)point;
{
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //创建CGPDFDocumentRef对象
    CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPath]);//沙盒中的文件路径
//    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)filename, NULL, NULL);//工程中的文件路径
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    
    //生成一个空的pdf上下文
    NSString *fileName = [NSString stringWithFormat:@"pdf_%d.pdf",arc4random_uniform(10000)];
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
            CGRect rect = CGRectMake(point.x, mediaBox.size.height - point.y - image.size.height, image.size.width, image.size.height);
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

+ (NSString *)generatePDFFromImage:(NSString *)imagePath password:(NSString *)pw;
{
    //生成pdf路径
    NSString *fileName = [NSString stringWithFormat:@"pdf_%d.pdf",arc4random_uniform(10000)];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *fileFullPath = [saveDirectory stringByAppendingPathComponent:fileName];

    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    const char *filepath = [fileFullPath UTF8String];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextRef pdfContext;
    CFStringRef path;
    CFURLRef url;
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef myDictionary = NULL;
    CFMutableDictionaryRef pageDictionary = NULL;
    
    path = CFStringCreateWithCString (NULL, filepath,
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    myDictionary = CFDictionaryCreateMutable(NULL,
                                             0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextTitle,
                         CFSTR("Photo from iPrivate Album"));
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextCreator,
                         CFSTR("iPrivate Album"));
    //添加密码
    if (pw) {
        CFStringRef password = (__bridge CFStringRef)pw;
        CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, password);
        CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, password);
    }
    //设置PDF页面参数
    pdfContext = CGPDFContextCreateWithURL (url, &rect, myDictionary);
    CFRelease(myDictionary);
    CFRelease(url);
    
    pageDictionary = CFDictionaryCreateMutable(NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    boxData = CFDataCreate(NULL,(const UInt8 *)&rect, sizeof (CGRect));
    CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
    CGPDFContextBeginPage (pdfContext, pageDictionary);
    //绘制图片数据
    [self drawImage:pdfContext rect:rect image:image];
    
    CGPDFContextEndPage (pdfContext);
    
    CGContextRelease (pdfContext);
    CFRelease(pageDictionary);
    CFRelease(boxData);
    
    return fileFullPath;
}

+ (NSString *)generateImageFromPDFPath:(NSString *)pdfPath;
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    path = CFStringCreateWithCString(NULL, [pdfPath UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, NO);
    CFRelease(path);
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL(url);
    
    int page = CGPDFDocumentGetNumberOfPages(pdfDocument);
    
    for (int i; i < page, path; i ++)
    {
        CGImageRef imageRef = PDFPageToCGImage(i,pdfDocument);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *fileName = [NSString stringWithFormat:@"pdf_%d.png",i];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [paths objectAtIndex:0];
        NSString *imagePath = [saveDirectory stringByAppendingPathComponent:fileName];
        
        [data writeToFile:imagePath atomically:NO];
        
        CGImageRelease(imageRef);
    }
    
    CFRelease(url);
    
    return nil;
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


//From apple: http://developer.apple.com/qa/qa2007/qa1509.html

CGContextRef CreateARGBBitmapContext (size_t pixelsWide, size_t pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We’ll use the entire image.
    //  size_t pixelsWide = CGImageGetWidth(inImage);
    //  size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    //colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    if (sizeof(bitmapData))
    {
        //NSLog(@"size %d",bitmapData);
        //free(bitmapData);
    }
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

CGImageRef PDFPageToCGImage(size_t pageNumber, CGPDFDocumentRef document)
{
    CGPDFPageRef	page;
    CGRect		pageSize;
    CGContextRef	outContext;
    CGImageRef	ThePDFImage;
    //CGAffineTransform ctm;
    page = CGPDFDocumentGetPage (document, pageNumber);
    if(page)
    {
        pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        
        outContext= CreateARGBBitmapContext (pageSize.size.width, pageSize.size.height);
        if(outContext)
        {
            CGContextDrawPDFPage(outContext, page);
            ThePDFImage= CGBitmapContextCreateImage(outContext);
            int *buffer;
            
            buffer = CGBitmapContextGetData(outContext);
            //NSLog(@"%d",buffer);
            free(buffer);
            
            CGContextRelease(outContext);
            CGPDFPageRelease(page);
            return ThePDFImage;  
        }
    }
    return NULL;
}

@end
