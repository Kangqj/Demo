//
//  ViewController.m
//  PDFDeal
//
//  Created by 康起军 on 16/3/3.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "UIImage+Generate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *drawBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [drawBtn addTarget:self action:@selector(drawPDF) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:drawBtn];
    
    [drawBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        CGSize size = CGSizeMake(80, 40);
        make.size.mas_equalTo(size);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(20);
        
        [drawBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor greenColor] size:size] forState:UIControlStateNormal];
    }];
    
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn addTarget:self action:@selector(sendPDF) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGSize size = CGSizeMake(80, 40);
        make.size.mas_equalTo(size);
        make.left.mas_equalTo(self.view.frame.size.width-80);
        make.top.mas_equalTo(20);
        
        [sendBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor redColor] size:size] forState:UIControlStateNormal];

    }];
    
}

- (void)drawPDF
{
    NSLog(@"drawPDF");
    [self createTextPdf:@"test1.pdf" size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-60) password:@"123" content:@"sagdgsdhgashjgdjhagskjdgkahjsgdkjhasgdkjhasguiyrieuwyroiwynbmnbz,vzmcxbn" font:10];
    
    [self createImagePdf:@"test2.pdf" password:@"123" image:[UIImage imageNamed:@"test.jpg"]];
    
    UIFont *fonts = [UIFont fontWithName:@"Helvetica" size:10];
    UIImage *image = [UIImage drawText:@"谁都很好看很恐惧疯狂的世界繁华看世界 v 你不想每次女吧额 u 花费多少风景都是昆明本命年" color:[UIColor redColor] font:fonts size:self.view.frame.size];
    [self createImagePdf:@"test3.pdf" password:@"123" image:image];
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *newFilePath = [saveDirectory stringByAppendingPathComponent:@"aaa.png"];
    [imgData writeToFile:newFilePath atomically:NO];
}


- (void)sendPDF
{
    NSLog(@"sendPDF");
}

-(void)createTextPdf:(NSString *)name size:(CGSize)size password:(NSString *)pw content:(NSString *)content font:(int)number
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *saveFileName = name;
    NSString *newFilePath = [saveDirectory stringByAppendingPathComponent:saveFileName];
    const char *filename = [newFilePath UTF8String];
    CGRect pageRect=CGRectMake(0, 0, size.width, size.height);
    // This code block sets up our PDF Context so that we can draw to it
    CGContextRef pdfContext;
    CFStringRef path;
    CFURLRef url;
    CFMutableDictionaryRef myDictionary = NULL;
    // Create a CFString from the filename we provide to this method when we call it
    path = CFStringCreateWithCString (NULL, filename,
                                      kCFStringEncodingUTF8);
    // Create a CFURL using the CFString we just defined
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    // This dictionary contains extra options mostly for ‘signing’ the PDF
    myDictionary = CFDictionaryCreateMutable(NULL, 0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("My PDF File"));
    CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("My Name"));
    
    //加密
    CFStringRef password = (__bridge CFStringRef)pw;
    if (password) {
        CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, password);
        CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, password);
    }
    
    // Create our PDF Context with the CFURL, the CGRect we provide, and the above defined dictionary
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    // Cleanup our mess
    CFRelease(myDictionary);
    CFRelease(url);
    // Done creating our PDF Context, now it’s time to draw to it
    // Starts our first page
    CGContextBeginPage (pdfContext, &pageRect);
    // Draws a black rectangle around the page inset by 50 on all sides
    CGContextStrokeRect(pdfContext, CGRectMake(50, 50, pageRect.size.width-100, pageRect.size.height-100));
    
//    CGFontRef font_ref =CGFontCreateWithFontName((CFStringRef)@"STHeitiTC-Medium");
    
    // Adding some text on top of the image we just added
//    CGContextSelectFont (pdfContext, "Helvetica", font, kCGEncodingMacRoman);
    UIFont *font = [UIFont boldSystemFontOfSize:number];
    CGContextSelectFont (pdfContext, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], number,kCGEncodingMacRoman);
    
    CGContextSetTextDrawingMode(pdfContext, kCGTextFill);
    CGContextSetRGBFillColor(pdfContext, 0.2, 0.3, 0.5, 1);
    const char *text =  (char *)[content UTF8String];
    CGContextShowTextAtPoint (pdfContext, 50, pageRect.size.height-100, text, strlen(text));
    /*
    UIFont *fonts = [UIFont fontWithName:@"Helvetica" size:font];
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{ NSFontAttributeName: fonts,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    CGContextSetFillColorWithColor(pdfContext, [UIColor blueColor].CGColor);
//    [content drawInRect:pageRect withAttributes:attributes];
    [content drawAtPoint:CGPointMake(100, 100) withAttributes:attributes];
    */
    // End text
    // We are done drawing to this page, let’s end it
    // We could add as many pages as we wanted using CGContextBeginPage/CGContextEndPage
    CGContextEndPage (pdfContext);
    // We are done with our context now, so we release it
    CGContextRelease (pdfContext);
}

- (void)createImagePdf:(NSString *)name password:(NSString *)pw image:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *fileFullPath = [saveDirectory stringByAppendingPathComponent:name];
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    
    const char *path = [fileFullPath UTF8String];
    CFDataRef data = (__bridge CFDataRef)imgData;
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CFStringRef password = (__bridge CFStringRef)pw;
    
    MyCreatePDFFile(data,rect, path, password);
}

void MyCreatePDFFile (CFDataRef data,
                      CGRect pageRect,
                      const char *filepath,
                      CFStringRef password)
{
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
    if (password) {
        CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, password);
        CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, password);
    }
    
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    CFRelease(myDictionary);
    CFRelease(url);
    pageDictionary = CFDictionaryCreateMutable(NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
    CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
    CGPDFContextBeginPage (pdfContext, pageDictionary);
    WQDrawContent(pdfContext,data,pageRect);
    CGPDFContextEndPage (pdfContext);
    
    CGContextRelease (pdfContext);
    CFRelease(pageDictionary);
    CFRelease(boxData);
}

void WQDrawContent(CGContextRef myContext,
                   CFDataRef data,
                   CGRect rect)
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider,
                                                         NULL,
                                                         NO,
                                                         kCGRenderingIntentDefault);
    CGContextDrawImage(myContext, rect, image);
    
    CGDataProviderRelease(dataProvider);
    CGImageRelease(image);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
