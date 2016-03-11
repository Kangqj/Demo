//
//  AssetsLibraryManager.m
//  PDFDeal
//
//  Created by coverme on 16/3/11.
//  Copyright © 2016年 康起军. All rights reserved.
//

#import "AssetsLibraryManager.h"

@implementation AssetsLibraryManager

+ (AssetsLibraryManager *)sharedManager
{
    static AssetsLibraryManager *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        inst = [[AssetsLibraryManager alloc] init];
    });
    return inst;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return self;
}

- (NSMutableArray *)getAlbumGroup
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [groups addObject:group];
        
    } failureBlock:^(NSError *error) {
        
    }];
    
    return groups;
}

- (NSMutableArray *)getAlbumPhotos:(ALAssetsGroup *)group
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        [photos addObject:result];
        
    }];
    
    return photos;
}

- (NSMutableArray *)getAllPhotos
{
    NSMutableArray *allPhotos = [[NSMutableArray alloc] init];
    
    for (ALAssetsGroup *group in [self getAlbumGroup])
    {
        NSMutableArray *photos = [self getAlbumPhotos:group];
        [allPhotos addObjectsFromArray:photos];
    }
    
    return allPhotos;
}

@end
