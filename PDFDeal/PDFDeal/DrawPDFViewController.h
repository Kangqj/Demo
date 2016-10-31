//
//  DrawPDFViewController.h
//  OpenPFDemo
//
//  Created by 康起军 on 16/2/26.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawPDFViewController : UIViewController

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) CGPDFDocumentRef pdfDocument;

- (instancetype)initWithPage:(NSInteger)pageNumber withPDFDoc:(CGPDFDocumentRef)pdfDoc;

@end
