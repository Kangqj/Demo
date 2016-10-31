//
//  DrawPDFView.m
//  OpenPFDemo
//
//  Created by 康起军 on 16/2/26.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import "DrawPDFView.h"

@implementation DrawPDFView

- (instancetype)initWithFrame:(CGRect)frame atPage:(NSInteger)pageNumber withPDFDoc:(CGPDFDocumentRef)pdfDoc
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        page = pageNumber;
        pdfDocument = pdfDoc;
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

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


@end
