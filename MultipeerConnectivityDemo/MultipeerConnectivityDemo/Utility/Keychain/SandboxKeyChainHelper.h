//
//  SandboxKeyChainHelper.h
//  CCPos
//
//  Created by Zhu Gang on 6/17/14.
//  Copyright (c) 2014 LogicLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SandboxKeyChainHelper : NSObject

+ (BOOL)saveObject:(id)value withKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;



@end
