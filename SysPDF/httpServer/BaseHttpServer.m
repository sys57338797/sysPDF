//
//  BaseHttpServer.m
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "BaseHttpServer.h"
#import "httpServerContext.h"
#import "HSLogger.h"


@interface BaseHttpServer ()

@property (nonatomic, strong) NSMutableArray *requestIDList;

@end


@implementation BaseHttpServer

- (id)init
{
    self = [super init];
    if (self) {
        
        _delegate = nil;
        _paramSource = nil;
        _requestStatus = BaseHttpServerRequestStatusDefault;
        
        if ([self conformsToProtocol:@protocol(BaseHttpServerDelegate)]) {
            self.child = (id <BaseHttpServerDelegate>)self;
        }
//        else {
//            NSLog(@"warning ！！！===》 %@ not inheritance BaseHttpServerDelegate",self.description);
//        }
    }
    
    return self;
}

#pragma mark 请求接口
- (void)requestData
{
    //是否有依赖httpServer
    NSOperation *dependenOperation = [self isWantDependencyOperation];
    NSOperation *curOperation = self.operation;
    
    if (dependenOperation) {
        //添加依赖
        if (curOperation) {
            [curOperation addDependency:dependenOperation];
            [[BaseHttpServerManager sharedInstance] startOperation:dependenOperation];
        }
    }
    
    if (curOperation) {
        //开始执行
        [[BaseHttpServerManager sharedInstance] startOperation:curOperation];
    }
}

#pragma mark 返回请求操作
- (NSOperation *)operation
{
    
    NSDictionary *params = nil;
    
    //向paramSource取参数
//    params = [self requestParamsForServer];
    
    [HSLogger logWithHttpServer:self];
    
    if (self.requestParam) {
        params = [NSDictionary dictionaryWithDictionary:self.requestParam];
    }
    else {
//        NSLog(@"接口没有参数！！！");
        return nil;
    }
    
    //组装参数
    params = [self configParams:params];
    //获取请求操作
    return [self requestDataOperationWithParam:params];
    
}

- (NSBlockOperation *)requestDataOperationWithParam:(NSDictionary *)params
{
    __block NSInteger requestId = -1;
    
     return [NSBlockOperation blockOperationWithBlock:^{
        if (self.isNetWorkReachable) {
            if ([self.child requestUrl].length > 0) {
                switch (self.child.requestType) {
                    case BaseHttpServerRequestTypeGet:
                    {
                        requestId = [[BaseHttpServerManager sharedInstance] callGETWithParams:params url:[self.child requestUrl] success:^(HttpResponse *response) {
                            [self requestSuccess:response];
                        } fail:^(HttpResponse *response) {
                            
                            [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                        }];
                        break;
                    }
                    case BaseHttpServerRequestTypeSynPost:
                    {
                        HttpResponse *response = [[BaseHttpServerManager sharedInstance] callSynPOSTWithParams:params url:[self.child requestUrl]];
                        if (response.status == HttpResponseStatusSuccess) {
                            [self requestSuccess:response];
                        }
                        else {
                            [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                        }
                        break;
                    }
                    case BaseHttpServerRequestTypeAsynPost:
                    {
                        requestId = [[BaseHttpServerManager sharedInstance] callAsynPOSTWithParams:params url:[self.child requestUrl] success:^(HttpResponse *response) {
                            [self requestSuccess:response];
                        } fail:^(HttpResponse *response) {
                            
                            [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                        }];
                        break;
                    }
                    case BaseHttpServerRequestTypeAsynPostAndUpdateFile:
                    {
                        requestId = [[BaseHttpServerManager sharedInstance] callAsynPOSTWithParams:params url:[self.child requestUrl] updateFileData:self.updateData success:^(HttpResponse *response) {
                            [self requestSuccess:response];
                        } fail:^(HttpResponse *response) {
                            
                            [self requestFail:response requestStatus:BaseHttpServerRequestStatusDefault];
                        }];
                        break;
                    }
                        
                    default:
                        break;
                }
                
                if (requestId != -1) {
                    [self.requestIDList addObject:@(requestId)];
                }
                
            }
            else {
                [self requestFail:nil requestStatus:BaseHttpServerRequestStatusNonMainIP];
            }
        }
        else {
            [self requestFail:nil requestStatus:BaseHttpServerRequestStatusNoNetWork];
        }
    }];
    
}

#pragma mark 统一接收接口请求成功
- (void)requestSuccess:(HttpResponse*)response
{
    _requestStatus = BaseHttpServerRequestStatusSuccess;
    [self removeRequestIdWithRequestID:response.requestId];
    
    if ([self parseRequestSuccessReturnValue:response]) {
        [HSLogger logWithHttpServer:self HttpResponse:response];
        [self performSelectorOnMainThread:@selector(requestCallDidSuccess) withObject:nil waitUntilDone:YES];
    }
    else {
        [self requestFail:response requestStatus:BaseHttpServerRequestStatusFailCode];
    }
}

#pragma mark 统一接收接口请求失败
- (void)requestFail:(HttpResponse*)response requestStatus:(BaseHttpServerRequestStatus)status
{
    [HSLogger logWithHttpServer:self HttpResponse:response];
    _requestStatus = status;
    //解析上层返回的状态
    if (status == BaseHttpServerRequestStatusDefault) {
        if (response) {
            switch (response.status) {
                case HttpResponseStatusErrorTimeout:
                    _requestStatus = BaseHttpServerRequestStatusTimeout;
                    break;
                case HttpResponseStatusErrorNoNetwork:
                    _requestStatus = BaseHttpServerRequestStatusNoNetWork;
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    [self removeRequestIdWithRequestID:response.requestId];
    
    [self parseRequestFailReturnValue:response];

    [self performSelectorOnMainThread:@selector(requestCallDidFailed) withObject:nil waitUntilDone:YES];
}

#pragma mark 是否需要依赖操作
- (NSOperation*)isWantDependencyOperation
{
    return nil;
}

- (BOOL)parseRequestSuccessReturnValue:(HttpResponse*)response
{
    return YES;
}

- (void)parseRequestFailReturnValue:(HttpResponse*)response
{
    NSLog(@"super parseRequestFailReturnValue");
}

//#pragma mark 根据reformer对象获取不同的数据
//- (id)fetchDataWithReformer:(id<BaseHttpServerCallbackDataReformer>)reformer
//{
//    NSLog(@"super fetchDataWithReformer");
//    return nil;
//}

#pragma mark 配置参数
- (NSDictionary*)configParams:(NSDictionary*)params
{
    return params;
}

#pragma mark 请求参数
- (NSDictionary *)requestParamsForServer
{
    if (self.paramSource&&[self.paramSource respondsToSelector:@selector(requestParamsForServer:)]) {
        return [self.paramSource requestParamsForServer:self];
    }
    
    return nil;
}

- (void)requestCallDidSuccess
{
    [self beforeRequestCallSuccess];
    [self.delegate requestCallDidSuccess:self];
}

- (void)requestCallDidFailed
{
    [self beforeRequestCallFail];
    [self.delegate requestCallDidFailed:self];
}

- (void)beforeRequestCallSuccess
{
    if (self.extensionDelegate&&[self.extensionDelegate respondsToSelector:@selector(extensionBeforeRequestCallSuccess:)]) {
        [self.extensionDelegate extensionBeforeRequestCallSuccess:self];
    }
}

- (void)beforeRequestCallFail
{
    if (self.extensionDelegate&&[self.child respondsToSelector:@selector(extensionBeforeRequestCallFail:)]) {
        [self.extensionDelegate extensionBeforeRequestCallFail:self];
    }
}

#pragma mark 取消当前server起飞的所有http请求
- (void)cancelAllRequests
{
    [[BaseHttpServerManager sharedInstance] cancelRequestWithRequestIDArray:self.requestIDList];
    [self.requestIDList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[BaseHttpServerManager sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIDList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIDList removeObject:requestIDToRemove];
    }
}

- (NSString*)BaseHttpServerRequestType
{
    if (self.child) {
        switch ([self.child requestType]) {
        case BaseHttpServerRequestTypeGet:
            return @"BaseHttpServerRequestTypeGet";
            case BaseHttpServerRequestTypeSynPost:
                return @"BaseHttpServerRequestTypeSynPost";
            case BaseHttpServerRequestTypeAsynPost:
                return @"BaseHttpServerRequestTypeAsynPost";
            case BaseHttpServerRequestTypeAsynPostAndUpdateFile:
                return @"BaseHttpServerRequestTypeAsynPostAndUpdateFile";
            case BaseHttpServerRequestTypeRestGet:
                return @"BaseHttpServerRequestTypeRestGet";
            case BaseHttpServerRequestTypeRestPost:
                return @"BaseHttpServerRequestTypeRestPost";
        default:
            break;
        }
    }
    
    return @"";
}

- (NSString*)BaseHttpServerRequestStatus
{
    
    switch (self.requestStatus) {
        case BaseHttpServerRequestStatusDefault:
            return @"BaseHttpServerRequestStatusDefault";
        case BaseHttpServerRequestStatusSuccess:
            return @"BaseHttpServerRequestStatusSuccess";
        case BaseHttpServerRequestStatusTimeout:
            return @"BaseHttpServerRequestStatusTimeout";
        case BaseHttpServerRequestStatusNoNetWork:
            return @"BaseHttpServerRequestStatusNoNetWork";
        case BaseHttpServerRequestStatusFailCode:
            return @"BaseHttpServerRequestStatusFailCode";
        case BaseHttpServerRequestStatusNonMainIP:
            return @"BaseHttpServerRequestStatusNonMainIP";
            
            
        default:
            break;
    }
    return @"";
}

- (BOOL)isLoading
{
    return self.requestIDList.count;
}

- (BOOL)isNetWorkReachable
{
    return [BaseHttpServerManager sharedInstance].isNetWorkReachable;
}

- (NSMutableArray*)requestIDList
{
    if (!_requestIDList) {
        _requestIDList = [NSMutableArray array];
    }
    
    return _requestIDList;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIDList = nil;
}

@end
