//
//  ViewController.m
//  PDFDeal
//
//  Created by 康起军 on 16/3/3.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PDFViewController.h"

@interface ViewController () <MFMailComposeViewControllerDelegate>
{
    UIScrollView *pdfScrollView;
}

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
        make.top.mas_equalTo(120);
        
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
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn addTarget:self action:@selector(addPic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGSize size = CGSizeMake(80, 40);
        make.size.mas_equalTo(size);
        make.left.mas_equalTo(self.view.frame.size.width-80);
        make.top.mas_equalTo(sendBtn.mas_bottom).offset(20);
        
        [addBtn setBackgroundImage:[UIImage drawRoundRectImageWithColor:[UIColor blueColor] size:size] forState:UIControlStateNormal];
        
    }];
    
}

- (void)drawPDF
{
    PDFViewController *previewController = [[PDFViewController alloc] init];
    [self.navigationController pushViewController:previewController animated:YES];
    [previewController release];
    return;
    
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

//http://www.cocoachina.com/bbs/read.php?tid=83761
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

- (void)sendPDF
{
    NSLog(@"sendPDF");
    [self sendMailInApp];
}

#pragma mark - 在应用内发送邮件
//激活邮件功能
- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        NSLog(@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替");
        return;
    }
    if (![mailClass canSendMail]) {
        NSLog(@"用户没有设置邮件账户");
        return;
    }
    [self displayMailPicker];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"eMail主题"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject:@"coverme1200@163.com"];
    [mailPicker setToRecipients: toRecipients];
//    //添加抄送
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    [mailPicker setCcRecipients:ccRecipients];
//    //添加密送
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//    [mailPicker setBccRecipients:bccRecipients];
    
    // 添加一张图片
    UIImage *addPic = [UIImage imageNamed: @"test.jpg"];
    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
    
    //添加一个pdf附件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *file = [saveDirectory stringByAppendingPathComponent:@"test2.pdf"];

//    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
    NSData *pdf = [NSData dataWithContentsOfFile:file];
    [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"aaa.pdf"];
    
    NSString *emailBody = @"<font color='red'>eMail</font> 正文";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController: mailPicker animated:YES];
//    [mailPicker release];
}

- (void)addPic
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"images" ofType:@"png"];
    NSString *pdfPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"公文55.pdf"];
    [PDFUtil insertImage:imagePath onPDF:pdfPath atPage:3 position:CGPointMake(150, 150)];
    
    NSString *path = [PDFUtil generatePDFFromImage:imagePath password:@"123"];
    
    NSLog(@"%@",path);
    
    [PDFUtil generateImageFromPDFPath:pdfPath];
    return;
    
    UIImage *image = [UIImage imageNamed:@"images.png"];
    //创建CGPDFDocumentRef对象
    NSString *filename = @"test.pdf";
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)filename, NULL, NULL);
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    
    //生成一个空的pdf上下文
    NSString *fileName = [NSString stringWithFormat:@"公文%d.pdf",arc4random_uniform(100)];
    NSString *pdfPathOutput = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSLog(@"%@", pdfPathOutput);
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    CGContextRef pdfContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    CFMutableDictionaryRef pageDictionary = NULL;
    CFDataRef boxData = NULL;
    
    CGRect pageRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60);
    
    pageDictionary = CFDictionaryCreateMutable(NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
    CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
    
    //开始绘制
    //在BeginPage与EndPage之间绘制该页内容时调用
//    CGPDFContextBeginPage (pdfContext, pageDictionary);
    //先绘制原页数据
    //调整坐标系
//    CGContextTranslateCTM(pdfContext, 0.0, self.view.bounds.size.height);//先垂直下移height高度
//    CGContextScaleCTM(pdfContext, 1.0, -1.0);//再垂直向上翻转
    
    //绘制pdf内容
    NSInteger numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
    for (int i=1; i<=numberOfPages; i++)
    {
        CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, i);
        CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        
        CGContextBeginPage(pdfContext, &mediaBox);
        CGContextDrawPDFPage(pdfContext, page);
        
        if (i == 2)
        {
            CGRect rect = CGRectMake(10, mediaBox.size.height - 10 - image.size.height, image.size.width, image.size.height);
            drawPicture(pdfContext, rect, image);
        }
        
        CGContextEndPage(pdfContext);
    }
    
//    CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDocument, 1);
//    CGContextSaveGState(pdfContext);
//    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, self.view.bounds, 0, true);
//    CGContextConcatCTM(pdfContext, pdfTransform);
//    CGContextDrawPDFPage(pdfContext, pageRef);
//    CGContextRestoreGState(pdfContext);
    
//    CGPDFContextBeginPage (pdfContext, pageDictionary);
//    
//     //再调用drawPicture
//    CGRect rect = CGRectMake(10, pageRect.size.height - 10 - image.size.height, image.size.width, image.size.height);
//    drawPicture(pdfContext, rect, image);
//    
//    CGPDFContextEndPage (pdfContext);
    CGPDFContextClose(pdfContext);
    
    CGContextRelease(pdfContext);
    CGPDFDocumentRelease(pdfDocument);
    CFRelease(pdfURL);

    /*
     http://blog.sina.com.cn/s/blog_8dabcad30101qwcr.html
     http://www.cnblogs.com/salam/archive/2012/12/23/2830250.html
    @autoreleasepool {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (cancelLibraryProcess)
                           {
                               *stop = YES;
                           }
                           if (group == nil)
                           {
                               return;
                           }
                           if (self.isPhotoAlbum)
                           {
                               [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                           }
                           else
                           {
                               [group setAssetsFilter:[ALAssetsFilter allVideos]];
                           }
                           
                           if ([group numberOfAssets]!=0) {
                               if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:NSLocalizedString(@"Camera Roll",nil)]) {
                                   [self.assetGroups insertObject:group atIndex:0];
                               }
                               else{
                                   [self.assetGroups addObject:group];
                               }
                           }
                           // Reload albums
                           [self performSelectorOnMainThread:@selector(reloadVisibleTable) withObject:nil waitUntilDone:YES];
                       };
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           kLogI(@"get visible album data error:%@",error);
                           double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
                           if(version>=6.0f){
                               UIAlertView  *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                    message:NSLocalizedString(@"To import photos to hidden albums or browse your visible albums, CoverMe needs to access your camera roll. Your photos won’t be uploaded to CoverMe servers. Please permit CoverMe to access your photos from Settings->Privacy->Photos.", nil)
                                                                                   delegate:self
                                                                          cancelButtonTitle:nil
                                                                          otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
                               alertView.tag = 0x51;
                               [alertView show];
                               [alertView release];
                           }
                           else{
                               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                message:NSLocalizedString(@"CoverMe needs to access your camera rolls. Your photos and videos won’t be uploaded to CoverMe servers.", nil)
                                                                               delegate:self
                                                                      cancelButtonTitle:nil
                                                                      otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
                               alert.tag = 0x51;
                               [alert show];
                           }
                       };
                       // Enumerate Albums
                       [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                              usingBlock:assetGroupEnumerator
                                            failureBlock:assetGroupEnumberatorFailure];
                   });    
     
     
     */

}

#pragma -mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /*
     Printing description of info:
     {
     UIImagePickerControllerMediaType = "public.image";
     UIImagePickerControllerOriginalImage = "<UIImage: 0x175c6e40> size {1936, 2592} orientation 3 scale 1.000000";
     UIImagePickerControllerReferenceURL = "assets-library://asset/asset.JPG?id=4007A4D4-819F-4A3A-8600-AEE1684C3CFF&ext=JPG";
     }
     */
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    NSLog(@"%@", msg);
}


#pragma mark 绘制图片到pdf上面
//http://bbs.csdn.net/topics/390277037
//拿到原PDFDocumentRef：
CGPDFDocumentRef WQGetPDFDocumentRef(NSString *filename)
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    size_t count;
    
    path = CFStringCreateWithCString (NULL, [filename UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    count = CGPDFDocumentGetNumberOfPages (document);
    if (count == 0) {
        printf("[%s] needs at least one page!\n", [filename UTF8String]);
        return NULL;
    }
    return document;
}


//给你封装个画图片上去的方法
void drawPicture(CGContextRef myContext,CGRect rect, UIImage *image)
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

/*
void yourDrawPDFFunc(...)
{
    ...
    //在BeginPage与EndPage之间绘制该页内容时调用
    CGPDFContextBeginPage (pdfContext, pageDictionary);
    //先绘制原页数据
    //再调用drawPicture
    CGPDFContextEndPage (pdfContext);
    ....
}
*/

//http://blog.csdn.net/yiyaaixuexi/article/details/8209188

- (NSString *)pdfDestPath:(NSString *)filename
{
    return [NSHomeDirectory() stringByAppendingPathComponent:filename];
}

- (void)WQCreatePDFFileWithSrc:(NSData *)imgData
                    toDestFile:(NSString *)destFileName
                  withPassword:(NSString *)pw
{
    NSString *fileFullPath = [self pdfDestPath:destFileName];
    const char *path = [fileFullPath UTF8String];
    CFDataRef data = (__bridge CFDataRef)imgData;
    UIImage *image = [UIImage imageWithData:imgData];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CFStringRef password = (__bridge CFStringRef)pw;
    
    MyCreatePDFFile(data,rect, path, password);
}

//PDF合并
//http://www.cnblogs.com/tx8899/p/4082749.html
- (void)mergePDF

{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *filePath1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"阅办卡.pdf"];
    
    NSString *filePath2 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"文件.pdf"];
    
    NSArray *PDFURLS = [NSArray arrayWithObjects:filePath1,filePath2, nil];
    
    
    
    [self joinPDF:PDFURLS];
    
}



- (NSString *)joinPDF:(NSArray *)listOfPaths {
    
    // File paths
    
    NSString *fileName = [NSString stringWithFormat:@"公文%d.pdf",arc4random_uniform(100)];
    
    NSString *pdfPathOutput = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    
    
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    
    
    
    NSInteger numberOfPages = 0;
    
    // Create the output context
    
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    
    
    for (NSString *source in listOfPaths) {
        
        CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:source]);
        
        
        
        //file ref
        
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
        
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);
        
        
        
        // Loop variables
        
        CGPDFPageRef page;
        
        CGRect mediaBox;
        
        
        
        // Read the first PDF and generate the output pages
        
        //        NSLog(@"GENERATING PAGES FROM PDF 1 (%@)...", source);
        
        for (int i=1; i<=numberOfPages; i++) {
            
            page = CGPDFDocumentGetPage(pdfRef, i);
            
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            
            CGContextBeginPage(writeContext, &mediaBox);
            
            CGContextDrawPDFPage(writeContext, page);
            
            CGContextEndPage(writeContext);
            
        }
        
        
        
        CGPDFDocumentRelease(pdfRef);
        
        CFRelease(pdfURL);
        
    }
    
    CFRelease(pdfURLOutput);
    
    
    
    // Finalize the output file
    
    CGPDFContextClose(writeContext);
    
    CGContextRelease(writeContext);
    
    
    
    return pdfPathOutput;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
