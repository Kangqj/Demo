//
//  DrawPDFView.m
//  OpenPFDemo
//
//  Created by coverme on 16/2/26.
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
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //调整坐标系
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //绘制pdf内容
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdfDocument, page);
    CGContextSaveGState(context);
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(pageRef, kCGPDFCropBox, self.bounds, 0, true);
    CGContextConcatCTM(context, pdfTransform);
    CGContextDrawPDFPage(context, pageRef);
    CGContextRestoreGState(context);
}


@end
