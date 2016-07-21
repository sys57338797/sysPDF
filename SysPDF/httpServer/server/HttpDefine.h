//
//  HttpDefine.h
//  http相关宏定义
//  Created by mutouren on 15-6-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - aouth

/*
 * google翻译api      http://brisk.eu.org/api/translate.php?from=en&to=zh_CN&text=test
     有道api          http://fanyi.youdao.com/openapi.do?
 *
 *
 */


#define kTHEFIRSTHTTPURL            @"http://fanyi.youdao.com/openapi.do"




#pragma mark 接口错误代码
typedef NS_ENUM(NSUInteger, HttpErrorCodeTable) {
    HttpErrorDefault = -1,                      //默认标示
    HttpErrorSuccess = 0,                       //成功
    HttpErrorTextTooLonger = 20,                //要翻译的文本过长
    HttpErrorNonTranslation = 30,               //无法进行有效的翻译
    HttpErrorNonSupport = 40,                   //不支持的语言类型
    HttpErrorKeyInvalid = 50,                   //无效的key
    HttpErrorNonDictionary = 60,                //无词典结果，仅在获取词典结果生效
};



// *-- 域名转ip
extern NSString * const KHttpServiceDomainIP;


