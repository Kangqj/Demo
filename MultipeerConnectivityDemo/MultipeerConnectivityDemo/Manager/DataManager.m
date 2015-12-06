//
//  DataManager.m
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/3.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

@synthesize peerArr, downPath, bufferPath;

+ (DataManager *)sharedManager
{
    static DataManager *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (id)init
{
    if (self)
    {
        self = [super init];
        
        self.peerArr = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)createSandboxFolder
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *downFolder = [kDocumentsPath stringByAppendingPathComponent:@"download"];
    if (![manager fileExistsAtPath:downFolder])
    {
        [manager createDirectoryAtPath:downFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    self.downPath = downFolder;
    
    NSString *bufferFolder = [kDocumentsPath stringByAppendingPathComponent:@"buffer"];
    if (![manager fileExistsAtPath:bufferFolder])
    {
        [manager createDirectoryAtPath:bufferFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    self.bufferPath = bufferFolder;
}

@end
