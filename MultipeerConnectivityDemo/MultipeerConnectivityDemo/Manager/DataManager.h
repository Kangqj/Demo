//
//  DataManager.h
//  MultipeerConnectivityDemo
//
//  Created by 康起军 on 15/12/3.
//  Copyright © 2015年 coverme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (strong, nonatomic) NSMutableArray *peerArr;

+ (DataManager *)sharedManager;


@end
