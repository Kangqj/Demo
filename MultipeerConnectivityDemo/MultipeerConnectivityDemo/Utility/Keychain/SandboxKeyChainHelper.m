//
//  SandboxKeyChainHelper.m
//  CCPos
//
//  Created by Zhu Gang on 6/17/14.
//  Copyright (c) 2014 LogicLink. All rights reserved.
//

#import "SandboxKeyChainHelper.h"

@implementation SandboxKeyChainHelper

+ (BOOL)saveObject:(id)value withKey:(NSString *)key
{
    
    NSDictionary *dictQuery = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService:key,
                                (__bridge id)kSecAttrAccount:key,
                                (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlock};
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dictQuery, NULL);
    if(status == errSecSuccess)
    {
        if(!value)
        {
            status = SecItemDelete((__bridge CFDictionaryRef)dictQuery);
            
            return status == errSecSuccess;
        }
        else
        {
            NSDictionary *dictUpdateAttributes = @{(__bridge id)kSecValueData:[NSKeyedArchiver archivedDataWithRootObject:value]};
            status = SecItemUpdate((__bridge CFDictionaryRef)dictQuery, (__bridge CFDictionaryRef)dictUpdateAttributes);
            
            return status == errSecSuccess;
        }
        
    }
    else if(status == errSecItemNotFound)
    {
        if(value)
        {
            NSMutableDictionary *dictAddAttributes = [NSMutableDictionary dictionaryWithDictionary:dictQuery];
            dictAddAttributes[(__bridge id)kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:value];
            
            status = SecItemAdd((__bridge CFDictionaryRef)dictAddAttributes, NULL);
            
            return status == errSecSuccess;
        }
        else
            return YES;
        
    }
    else
        return NO;
}

+ (id)objectForKey:(NSString *)key
{
    NSDictionary *dictQuery = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService:key,
                                (__bridge id)kSecAttrAccount:key,
                                (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue,
                                (__bridge id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne};
    
    CFDataRef keyData = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)dictQuery, (CFTypeRef *)&keyData);
    if(status == errSecSuccess)
    {
        id value = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        
        if(keyData)
            CFRelease(keyData);
        
        return value;
    }
    
    return nil;
}


@end
