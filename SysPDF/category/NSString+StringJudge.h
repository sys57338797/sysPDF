//
//  NSString+StringJudge.h
//  CWGJCarOwner
//
//  Created by mutouren on 9/17/15.
//  Copyright (c) 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringJudge)

#pragma mark 判断字符串是否为web端的null,是返回@""
+ (NSString*)stringJudgeNullWithContent:(NSString*)content;

#pragma mark 验证转成NSNumber
- (BOOL)VerifyToNSNumber;

#pragma mark 验证车牌
- (BOOL)VerifyCarNo;

#pragma mark 验证手机号码
- (BOOL)VerifyPhone;

#pragma mark 验证短信验证码
- (BOOL)VerifySMSNote;

#pragma mark 判断是否是数字
- (BOOL)isNumText;

#pragma mark 判断是否是全英文
- (BOOL)isEnglishString;

#pragma mark 转换钱的小数点位数，只有小数点后一位的只取到小数点后1位，是整数的取整数,最多保留后2位
- (NSString*)getMoneyString;

- (NSString*)getMoneyStringWithDouble:(double)value;


#pragma mark 判断文件后缀
- (BOOL)fileExtensionsName:(NSString*)name;

@end
