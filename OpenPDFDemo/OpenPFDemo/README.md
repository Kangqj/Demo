>写这篇笔记的原因是之前的老项目遇到了一个问题：iOS9后PDF中文会显示乱码，而且试了各种方法都不行，还好最终找到了解决方法－－－MuPDF
>所以在此总结一下解决问题过程中使用过的方法：

![](http://www.icosky.com/icon/png/System/Rhor%20v2%20Part%203/PDF%20File.png)

#1.使用UIWebView加载

```
//代码很简单
UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
[self.view addSubview:webView];

NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
[webView loadRequest:request];
```

#2.使用QLPreviewController打开

```
//初始化QLPreviewController对象
QLPreviewController *previewController = [[QLPreviewController alloc] init];
previewController.dataSource = self;
[self.navigationController pushViewController:pageController animated:YES];

//再实现QLPreviewControllerDataSource的两个方法即可显示
//显示文件数量
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller；
//文件路径URL
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index；
```

#3.使用CGContextDrawPDFPage绘制
在`UIView `的`- (void)drawRect:(CGRect)rect`方法中绘制PDF内容，代码如下：

```
/*
Quartz2D              UIKit

y               (0, 0)|----------x
|                     |
|                     |
|                     |
|                     |
(0, 0) |---------x           y

*/
- (void)drawRect:(CGRect)rect {
// Drawing code

CGContextRef context = UIGraphicsGetCurrentContext();

//调整坐标系
CGContextTranslateCTM(context, 0.0, self.bounds.size.height);//先垂直下移height高度
CGContextScaleCTM(context, 1.0, -1.0);//再垂直向上翻转

//绘制pdf内容
CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDocument, page);
CGContextSaveGState(context);
CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, self.bounds, 0, true);
CGContextConcatCTM(context, pdfTransform);
CGContextDrawPDFPage(context, pageRef);
CGContextRestoreGState(context);
}
```

需要说明的是：
- Quartz 2D坐标系的原点在界面左下角，而UIKit坐标系的原点在左上角，所以需要对画布进行翻转，才能得到正确的视图；
- 方法中需要传入page和pdfDocument，CGContextDrawPDFPage是按照页码来一张张绘制的；

再放入`UIPageViewController`中来展示，翻页效果杠杠的（具体效果见最后Demo）。

##顺便说说UIPageViewController的使用
- `UIPageViewControllerde`感觉就像是一个书夹，其中每一页是一个`UIViewController`，页面内容在`UIViewController`的视图中绘制，翻页效果是自带的，你只要绘制好要展示的画面就好了；
- 在初始化`UIPageViewControllerde`对象的时候，就要加载第一页，避免开始时出现空白页；

- 在下面方法中写上一页，下一页的调用逻辑；

```
//加载某一页调用方法
- (void)setViewControllers:(nullable NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

//上一页视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
//下一页视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
```

- `UIPageViewControllerde`显示的内容没有缩放的功能，所以需要自己加。我是在`UIViewController`视图里面嵌了一层`UIScrollView`，设置其缩放系数`minimumZoomScale, maximumZoomScale`，然后实现下面的代理方法来实现缩放的。

```
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
```

当然，这也可以用其他方法来完成，比如：`UIPinchGestureRecognizer `

#4.MuPDF类库的使用

MuPDF官网：[http://www.mupdf.com/](http://www.mupdf.com/)

###  4.1 生成依赖包

1. 源码下载：`git clone --recursive git://git.ghostscript.com/mupdf.git
`；
2. 下载完成后，进入`mupdf/platform/ios`目录下；
3. 打开*MuPDF*工程;
4. 修改工程的Build Configuration为Release；
5. 选择iPhone模拟器，运行这个工程，这将生成i386或x86_64结构的.a包（根据你选择的模拟器类型）;
6. 连接你的iPhone，修改你自己的bundle identifier, certificate和 provisioning profile，在真机环境下运行该程序，这将会生成armv7，arm64架构的.a包；
7. 同理，修改工程的Build Configuration为Debug，可以生成Debug对应的.a包；
8. 进入`mupdf/build/ `，你会找到各个架构下的文件夹，里面包含了所有编译之后生成的包：
9. 现在，你可以使用`lipo`命令去合并些架构下的依赖包，这将会生成比较大的包；

![生成的依赖包目录](http://upload-images.jianshu.io/upload_images/670087-71f769e699da3b6f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

使用`lipo`命令合并.a包：

```
Last login: Mon Feb 29 20:43:50 on console
promote:~ mac$ cd /Users/mac/Desktop/lib 
promote:lib mac$ lipo -create libmupdf_arm64.a libmupdf_x86_64.a -output libmupdf.a
promote:lib mac$ lipo -info libmupdf.a
Architectures in the fat file: libmupdf.a are: x86_64 arm64 
promote:lib mac$ lipo -create libmupdfthird_arm64.a libmupdfthird_x86_64.a -output libmupdfthird.a
promote:lib mac$ lipo -info libmupdfthird.a
Architectures in the fat file: libmupdfthird.a are: x86_64 arm64 
promote:lib mac$ 

```

![lipo之后的包](http://upload-images.jianshu.io/upload_images/670087-001d65f9cbcbc14f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 我只合并了debug中的arm64和x86_64的包，要是再合并i386就太大了。

### 4.2 开始集成
1. 添加所需要的源码文件：
`mupdf/include/mupdf`路径下的所有头文件； 
`mupdf/platform/ios/classes `路径下的所有obj-c类；
`mupdf/platform/ios `路径下的`common.h，common .m`；
2. 添加之前生成好的依赖包到你的工程中；
3. 配置你工程的`Library Search Path `，添加依赖包的路径，
比如：`$(inherited) $(PROJECT_DIR)/External/MuPDF/lib/ `
4. 由于库中引用文件`#include "mupdf/fitz.h"`，使用`include`编译指令，所以头文件绝对路径=搜索路径+相对路径，
所以需要配置搜索路径`Header Search Paths`为`"$(SRCROOT)/OpenPFDemo/ThirdLib/include"`；

现在，你应该就可以运行你的程序了（具体的文件目录见Demo）。

### 4.3 提示：
1. 由于合并之后的依赖包比较大，所以为了减少你App的大小，你可以配置两个路径：
在release文件夹下添加`mupdf/build/release-ios-armv7-arm64 `路径下的依赖包；
在debug文件夹下添加`mupdf/build/debug-ios-arm64和debug-ios-x86_64`路径下的合并后的包；
- 在你的工程配置`Library Search Path `中，分别配置`Debug和Release`的路径；

这样你在模拟器和真机Debug环境下使用的就是Debug对应的依赖包，而在打包的时候使用的就是Release对应的依赖包，而不会包含其他依赖包。

## 4.4 注意
- 按照 [stackoverflow](http://stackoverflow.com/questions/7324014/develop-an-ebook-reader-on-iphone-ipad-using-mupdf-library/31111924#31111924)上面的这个问答的集成步骤在当前最新的*MuPDF*版本上集成时会有些出入，所以我修改了一下；
- 由于这个库包含了很多平台（见`platform`文件夹下），所以比较大，要等完全下载完成之后再使用；
- 下载完成之后，运行其中的iOS代码，发现居然报错了（我用的xcode7.0）

![报错](http://upload-images.jianshu.io/upload_images/670087-469f46227acd5774.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

解决方法：将`MuDocumentController.m`中的`pdf_write_document(ctx, idoc, tmp, &opts);`改为`pdf_create_document(ctx);`即可；

##4.6 使用打开PDF

- 首先，在程序启动后，初始化相关参数：

```
enum
{
ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
};

queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
fz_register_document_handlers(ctx);
```

- 然后调用下面方法打开：

```
- (void)openMuPDF:(NSString *)path name:(NSString *)name
{
    _filePath = malloc(strlen([path UTF8String])+1);
    
    strcpy(_filePath, [path UTF8String]);
    
    dispatch_sync(queue, ^{});
    
    printf("open document '%s'\n", _filePath);
    
    _filename = [name retain];
    
    doc = [[MuDocRef alloc] initWithFilename:_filePath];
    if (!doc) {
        
        return;
    }
    
    if (fz_needs_password(ctx, doc->doc))
    {
        [self askForPassword: @"'%@' needs a password:"];
    }
    else
    {
        [self onPasswordOkay];
    }
}

- (void)askForPassword: (NSString*)prompt
{
    UIAlertView *passwordAlertView = [[UIAlertView alloc]
                                      initWithTitle: @"Password Protected"
                                      message: [NSString stringWithFormat: prompt, [_filename lastPathComponent]]
                                      delegate: self
                                      cancelButtonTitle: @"Cancel"
                                      otherButtonTitles: @"Done", nil];
    [passwordAlertView setAlertViewStyle: UIAlertViewStyleSecureTextInput];
    [passwordAlertView show];
    [passwordAlertView release];
}

- (void)onPasswordOkay
{
    MuDocumentController *document = [[MuDocumentController alloc] initWithFilename:_filename path:_filePath document:doc];
    if (document) {
        [self setTitle: @"Library"];
        [[self navigationController] pushViewController:document animated:YES];
        [document release];
    }
    [_filename release];
    free(_filePath);
}
```

参考资料：

- [http://blog.csdn.net/yiyaaixuexi/article/details/7645725]()
- [http://stackoverflow.com/questions/7324014/develop-an-ebook-reader-on-iphone-ipad-using-mupdf-library/31111924#31111924]()

***
Demo下载链接：[OpenPDFDemo](https://github.com/Kangqj/Demo/tree/master/OpenPDFDemo)

[@Kangqj](http://www.jianshu.com/users/1161c7b62af8/latest_articles)
