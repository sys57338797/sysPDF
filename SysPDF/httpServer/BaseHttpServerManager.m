//
//  BaseHttpServerManager.m
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "BaseHttpServerManager.h"
#import "NSURLRequest+RequestParams.h"
#import "HttpServerContext.h"
#import "HttpSignatureGenerator.h"



@interface BaseHttpServerManager ()

@property (nonatomic, strong) NSMutableDictionary *requestTable;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) NSNumber *requestID;
@property (nonatomic, strong) NSOperationQueue *mainQueue;

@end

@implementation BaseHttpServerManager


#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static BaseHttpServerManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BaseHttpServerManager alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    NSURLRequest *request = [self httpGetRequestWithUrl:url requestParams:params];
    NSInteger resquestID = [self callHttpWithRequest:request success:success fail:fail];
    return resquestID;
}

- (HttpResponse*)callSynPOSTWithParams:(NSDictionary *)params url:(NSString *)url
{
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
     AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requestOperation setResponseSerializer:responseSerializer];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    
    return [[HttpResponse alloc] initWithResponseRequestID:nil request:requestOperation.request responseData:requestOperation.responseData error:requestOperation.error];
}

- (NSInteger)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params];
    NSInteger resquestID = [self callHttpWithRequest:request success:success fail:fail];
    return resquestID;
}

- (NSInteger)callAsynPOSTWithParams:(NSDictionary *)params url:(NSString *)url updateFileData:(NSData*)data success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    NSURLRequest *request = [self httpPOSTRequestWithUrl:url requestParams:params fileData:data];
    NSInteger resquestID = [self callHttpWithRequest:request success:success fail:fail];
    return resquestID;
}

#pragma mark 起飞的最后一步，如果需要更换http第三方请求库，只需要在这里替换
- (NSInteger)callHttpWithRequest:(NSURLRequest*)request success:(HttpSuccessBlock)success fail:(HttpFailureBlock)fail
{
    
    NSNumber *requestID = [self getRequestID];
    
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        AFHTTPRequestOperation *storedOperation = self.requestTable[requestID];
        if (!storedOperation) {
            return;
        }
        else {
            [self.requestTable removeObjectForKey:requestID];
        }
        
        HttpResponse *response = [[HttpResponse alloc] initWithResponseRequestID:requestID request:operation.request responseData:operation.responseData error:nil];
        
        success?success(response):nil;
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        AFHTTPRequestOperation *storedOperation = self.requestTable[requestID];
        if (!storedOperation) {
            return;
        }
        else {
            [self.requestTable removeObjectForKey:requestID];
        }
        
        HttpResponse *response = [[HttpResponse alloc] initWithResponseRequestID:requestID request:operation.request responseData:operation.responseData error:error];
        
        fail?fail(response):nil;
    }];
    
    
    self.requestTable[requestID] = httpRequestOperation;
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    return [requestID integerValue];
}

#pragma mark 返回"GET"方式的NSURLRequest
- (NSURLRequest*)httpGetRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:url parameters:params error:NULL];
    
//    NSDictionary *header = [self makeRESTHeader];
//    
//    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [request setValue:obj forHTTPHeaderField:key];
//    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark 返回"POST"方式的NSURLRequest
- (NSURLRequest*)httpPOSTRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:url parameters:params error:NULL];
    
    NSDictionary *header = [self makeRESTHeader];
    
    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark 返回"POST"方式的NSURLRequest,HTTP body带上传数据
- (NSURLRequest*)httpPOSTRequestWithUrl:(NSString*)url requestParams:(NSDictionary*)params fileData:(NSData*)data
{
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *name = @"userId";
        [formData appendPartWithFileData:data name:@"File" fileName:[name stringByAppendingString:@".jpg"] mimeType:@"image/jpg"];
    } error:NULL];
    
    NSDictionary *header = [self makeRESTHeader];
    
    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.requestParams = params;
    
    return request;
}

#pragma mark 创建REST头部
- (NSDictionary*)makeRESTHeader
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    NSString *cookie = @"";
    if (cookie) {
        [headerDic setObject:cookie forKey:@"Cookie"];
    }
    return headerDic;
}

#pragma mark 取消已起飞的http
- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSOperation *requestOperation = self.requestTable[requestID];
    [requestOperation cancel];
    [self.requestTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDArray:(NSArray *)requestIDArray
{
    for (NSNumber *requestId in requestIDArray) {
        [self cancelRequestWithRequestID:requestId];
    }
}

- (void)startOperation:(NSOperation*)operation
{
    [self.mainQueue addOperation:operation];
}

#pragma mark 获取请求ID
- (NSNumber*)getRequestID
{
    if (!_requestID) {
        _requestID = @(1);
    }
    else {
        if ([_requestID integerValue] == NSIntegerMax) {
            _requestID = @(1);
        }
        else {
            _requestID = @([_requestID integerValue]+1);
        }
    }
    
    return _requestID;
}

- (NSMutableDictionary*)requestTable
{
    if (!_requestTable) {
        _requestTable = [[NSMutableDictionary alloc] init];
    }
    
    return _requestTable;
}

- (AFHTTPRequestOperationManager*)operationManager
{
    if (!_operationManager) {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return _operationManager;
}

- (AFHTTPRequestSerializer*)httpRequestSerializer
{
    if (!_httpRequestSerializer) {
        // 设置超时时间
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        [_httpRequestSerializer willChangeValueForKey:@"timeoutInterval"];
        _httpRequestSerializer.timeoutInterval = 10.0f;
        [_httpRequestSerializer didChangeValueForKey:@"timeoutInterval"];
        _httpRequestSerializer.HTTPShouldHandleCookies = NO;
    }
    return _httpRequestSerializer;
}

- (NSOperationQueue*)mainQueue
{
    if (!_mainQueue) {
        _mainQueue = [[NSOperationQueue alloc] init];
    }
    
    return _mainQueue;
}

- (BOOL)isNetWorkReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

@end
