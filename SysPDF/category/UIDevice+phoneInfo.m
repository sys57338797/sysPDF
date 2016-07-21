//
//  UIDevice+phoneInfo.m
//  CWGJCarOwner
//
//  Created by mutouren on 9/18/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import "UIDevice+phoneInfo.h"
#import <sys/utsname.h>


@implementation UIDevice (phoneInfo)

#pragma mark 是否是ios7
+ (BOOL)isIOS7
{
    float v = [self getIOSVersion];
    
    if (v < 8) {
        return YES;
    }
    
    return NO;
}

#pragma mark 返回系统版本
+ (float)getIOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark 返回是否是iphone4,4s,5,5s机型的宽度
+ (BOOL)isIPhone4Width
{
    if ([self isIphone4And4s]||[self isIphone5And5s]) {
        return YES;
    }
    
    return NO;
}

#pragma mark 判断是否是iphone4和4s机型
+ (BOOL)isIphone4And4s
{
    NSString *model = deviceName();
    
    if (model.length > 0) {
        if ([model isEqualToString:@"iPod4,1"]
            ||[model isEqualToString:@"iPhone3,1"]
            ||[model isEqualToString:@"iPhone3,3"]
            ||[model isEqualToString:@"iPhone4,1"]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 判断是否是iphone5和5s机型
+ (BOOL)isIphone5And5s
{
    NSString *model = deviceName();
    
    if (model.length > 0) {
        if ([model isEqualToString:@"iPod5,1"]
            ||[model isEqualToString:@"iPhone5,1"]
            ||[model isEqualToString:@"iPhone5,2"]
            ||[model isEqualToString:@"iPhone5,3"]
            ||[model isEqualToString:@"iPhone5,4"]
            ||[model isEqualToString:@"iPhone6,1"]
            ||[model isEqualToString:@"iPhone6,2"]) {
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)isIphone6P
{
    NSString *model = deviceName();
    
    if (model.length > 0) {
        if ([model isEqualToString:@"iPhone7,1"]||[model isEqualToString:@"iPhone8,1"]) {
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)isIphone6
{
    NSString *model = deviceName();
    
    if (model.length > 0) {
        if ([model isEqualToString:@"iPhone7,2"]||[model isEqualToString:@"iPhone8,2"]) {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark 返回机型信息
NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
