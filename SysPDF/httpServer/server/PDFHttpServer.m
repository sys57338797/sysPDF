//
//  CarParkHttpServer.m
//  test
//
//  Created by mutouren on 12/25/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "PDFHttpServer.h"
#import "HttpServerContext.h"
#import "HttpSignatureGenerator.h"
#import "YRJSONAdapter.h"
#import "encrypt.h"


@interface PDFHttpServer () <BaseHttpServerDelegate>


@end


@implementation PDFHttpServer


#pragma mark 
- (NSOperation*)operation
{
    [self clearReturnContent];
    return [super operation];
}

#pragma mark 当接口调用成功时，需要去验证返回的错误码是否正确，如果错误将走错误的流程
- (BOOL)parseRequestSuccessReturnValue:(HttpResponse *)response
{
    if ([response.content isKindOfClass:[NSDictionary class]]) {
        _returnCode = (HttpErrorCodeTable)[[response.content objectForKey:@"errorCode"] integerValue];
        
        if (response.content) {
            _returnContent = [response.content copy];
        }
        
        if (self.returnCode == HttpErrorSuccess) {
            [self fetchData];
            return YES;
        }
    }
    
    
    return NO;
}

- (void)parseRequestFailReturnValue:(HttpResponse *)response
{
    switch (self.requestStatus) {
        case BaseHttpServerRequestStatusNoNetWork:
            _returnMsg = @"当前无网络连接";
            break;
        case BaseHttpServerRequestStatusTimeout:
            _returnMsg = @"网络请求超时";
            break;
        case BaseHttpServerRequestStatusNonMainIP:
            _returnMsg = @"无法连接服务器";
            break;
            
        default:
        {
            switch (self.returnCode) {
                case HttpErrorTextTooLonger:
                    _returnMsg = @"要翻译的文本过长";
                    break;
                case HttpErrorNonTranslation:
                    _returnMsg = @"无法进行有效的翻译";
                    break;
                case HttpErrorNonSupport:
                    _returnMsg = @"不支持的语言类型";
                    break;
                case HttpErrorKeyInvalid:
                    _returnMsg = @"无效的key";
                    break;
                case HttpErrorNonDictionary:
                    _returnMsg = @"无词典结果，仅在获取词典结果生效";
                    break;
                    
                    
                default:
                    _returnMsg = @"未知错误！！！";
                    break;
            }
            break;
        }
           
    }
}


#pragma mark 解析数据
- (void)fetchData
{
    
    _wordObj = [PDFWordObj objWithDictionary:self.returnContent];
}

#pragma mark
- (NSDictionary*)configParams:(NSDictionary*)params
{
    NSMutableDictionary *defaultParam = nil;
    if (params) {
        defaultParam = [NSMutableDictionary dictionary];
        [defaultParam setObject:[httpServerContext sharedInstance].keyfrom forKey:@"keyfrom"];
        [defaultParam setObject:[httpServerContext sharedInstance].key forKey:@"key"];
        [defaultParam setObject:[httpServerContext sharedInstance].type forKey:@"type"];
        [defaultParam setObject:[httpServerContext sharedInstance].doctype forKey:@"doctype"];
        [defaultParam setObject:[httpServerContext sharedInstance].version forKey:@"version"];
        [defaultParam addEntriesFromDictionary:params];
    }
    
    
    return defaultParam;
}

//#pragma 创建post参数
//- (NSDictionary*)makeParamsDictionaryWithServiceID:(NSString*)serviceID encryption:(NSString*)encryption signature:(NSString*)signature
//{
//    if (!serviceID || serviceID.length <= 0 || !signature || signature.length <= 0 || !encryption || encryption.length <= 0) {
//        return nil;
//    }
//    
//    
//    NSMutableDictionary *defaultParam =  [NSMutableDictionary dictionary];
//    [defaultParam setObject:serviceID forKey:@"service_id"];
//    [defaultParam setObject:[httpServerContext sharedInstance].appType forKey:@"app_type"];
//    [defaultParam setObject:[httpServerContext sharedInstance].verName forKey:@"ver_name"];
//    [defaultParam setObject:encryption forKey:@"content"];
//    [defaultParam setObject:signature forKey:@"sign"];
//    
//    return defaultParam;
//}

- (NSData*)aes256EncryptWithParams:(NSDictionary*)params encryptKey:(NSString*)key
{
    NSString *json = [params JSONString];
//    //去掉换行符“\n”和空格
//    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    json = [json stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [json aes256_encrypt_NSDataWithKey:key];
}

- (NSData*)aes256DecodeWithData:(NSData*)data decodeKey:(NSString*)key
{
    return [data aes256_decrypt:key];
}

- (NSString*)base64EncryptWithData:(NSData*)data
{
    return [NSData base64Encode:data];
}

- (NSData*)base64DecodeWithString:(NSString*)string
{
    return [NSData base64Decode:string];
}

- (void)clearReturnContent
{
    _returnCode = HttpErrorDefault;
    _returnContent = nil;
    _returnMsg = nil;
}

- (void)requestPDFWordInfoWithWord:(NSString*)word
{
    _wordObj = nil;
    self.requestParam = @{@"q":word};
    
    [self requestData];
}

- (NSString*)requestUrl
{
    return kTHEFIRSTHTTPURL;
}

- (NSString*)serviceID
{
    return nil;
}

- (BaseHttpServerRequestType)requestType
{
    return BaseHttpServerRequestTypeGet;
}


@end
