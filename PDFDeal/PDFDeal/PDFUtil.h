//
//  PDFUtil.h
//  PDFDeal
//
//  Created by Kangqijun on 16/7/6.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFUtil : NSObject

+ (void)insertImage:(NSString *)imagePath onPDF:(NSString *)pdfPath atPage:(int)page position:(CGPoint)point;

+ (NSString *)generatePDFFromImage:(NSString *)imagePath password:(NSString *)pw;

+ (NSString *)generateImageFromPDFPath:(NSString *)pdfPath;


@end
