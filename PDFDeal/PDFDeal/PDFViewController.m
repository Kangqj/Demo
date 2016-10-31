//
//  PDFViewController.m
//  PDFDeal
//
//  Created by 康起军 on 16/7/9.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "PDFViewController.h"
#import "DrawPDFViewController.h"

@interface PDFViewController () <UIPageViewControllerDataSource>


@end

@implementation PDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int num = 7;
    float width = self.view.frame.size.width/num;
    
    for (int i = 0; i < num; i ++)
    {
        UIButton *funButton = [UIButton buttonWithType:UIButtonTypeCustom];
        funButton.frame = CGRectMake(i*width, self.view.frame.size.height-40, width, 40);
        [funButton addTarget:self action:@selector(funButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:funButton];
    }

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
}

- (void)drawPDF
{
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                       forKey: UIPageViewControllerOptionSpineLocationKey];
    
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                         options:options];
    pageController.dataSource = self;
    DrawPDFViewController *pdfController = [self getViewControllerWithPage:1];
    
    NSArray *viewControllers =[NSArray arrayWithObject:pdfController];
    [pageController setViewControllers:viewControllers
                             direction:UIPageViewControllerNavigationDirectionForward
                              animated:NO
                            completion:nil];
    
//    [self.navigationController pushViewController:pageController animated:YES];
    [self.view addSubview:pageController.view];
    [self addChildViewController:pageController];
    [pageController release];
}

- (DrawPDFViewController *)getViewControllerWithPage:(NSInteger)page
{
    NSString *filename = @"test.pdf";
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)filename, NULL, NULL);
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
    CFRelease(pdfURL);
    
    DrawPDFViewController *pdfController = [[DrawPDFViewController alloc] initWithPage:page withPDFDoc:pdfDocument];
    
    return pdfController;
}

#pragma - mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    DrawPDFViewController *controller = (DrawPDFViewController *)viewController;
    
    if (controller.page-1 < 1)
    {
        return nil;
    }
    
    return [self getViewControllerWithPage:controller.page-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    DrawPDFViewController *controller = (DrawPDFViewController *)viewController;
    long pageSum = CGPDFDocumentGetNumberOfPages(controller.pdfDocument);
    
    if (controller.page+1 > pageSum)
    {
        return nil;
    }
    return [self getViewControllerWithPage:controller.page+1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
