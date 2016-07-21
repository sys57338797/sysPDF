//
//  BaseHttpServerManager.h
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//  请求管理者类，当需要更换请求方式时，在这个类更换

#import <Foundation/Foundation.h>
#import "HttpResponse.h"
#import "AFNetworking.h"


static NSTimeInterval kAIFNetworkingTimeoutSeconds = 10.0f;

typedef void (^HttpFailureBlock)(HttpResponse* response);
typedef void (^HttpSuccessBlock)(HttpResponse* response);

typedef void (^AFNetworkFormDataBlock)(id <AFMultipartFormData> formData);



@interface BaseHttpServerManager : NSObject

@property (nonatomic, readonly) BOOL isNetWorkReachable;    //是否有网络

+ (instancetype)sharedInstance;

#pragma mark 创建get请求
- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString*)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

#pragma mark 同步post请求
- (HttpResponse*)callSynPOSTWithParams:(NSDictionary *)params url:(NSString *)url;

#pragma mark 异步post请求
- (NSInteger)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString*)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

#pragma mark 异步post请求,HTTP body带上传数据
- (NSInteger)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url updateFileData:(NSData*)data success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail;

#pragma mark 

#pragma mark 取消已起飞的http
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

- (void)cancelRequestWithRequestIDArray:(NSArray *)requestIDArray;

#pragma mark 开始执行
- (void)startOperation:(NSOperation*)operation;

@end
