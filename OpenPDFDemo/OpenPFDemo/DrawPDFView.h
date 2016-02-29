//
//  DrawPDFView.h
//  OpenPFDemo
//
//  Created by 康起军 on 16/2/26.
//  Copyright © 2016年 Kangqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawPDFView : UIView
{
    CGPDFDocumentRef pdfDocument;
    NSInteger        page;
}

- (instancetype)initWithFrame:(CGRect)frame atPage:(NSInteger)page withPDFDoc:(CGPDFDocumentRef)pdfDoc;


@end
