//
//  AssetsLibraryManager.h
//  PDFDeal
//
//  Created by coverme on 16/3/11.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetsLibraryManager : NSObject
{
    ALAssetsLibrary *assetsLibrary;
}

+ (AssetsLibraryManager *)sharedManager;

- (NSMutableArray *)getAllPhotos;

@end
