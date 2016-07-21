//
//  UIDevice+phoneInfo.h
//  CWGJCarOwner
//
//  Created by mutouren on 9/18/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (phoneInfo)

#pragma mark 是否是ios7
+ (BOOL)isIOS7;

#pragma mark 返回是否是iphone4,4s,5,5s机型的宽度
+ (BOOL)isIPhone4Width;

#pragma mark 判断是否是iphone4和4s机型
+ (BOOL)isIphone4And4s;

#pragma mark 判断是否是iphone5和5s机型
+ (BOOL)isIphone5And5s;

#pragma mark 判断是否是6P或6sP
+(BOOL)isIphone6P;

#pragma mark 判断是否是6或6s
+(BOOL)isIphone6;


@end
