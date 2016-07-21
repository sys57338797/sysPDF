//
//  NSURLRequest+AIFNetworkingMethods.m
//  RTNetworking
//
//  Created by casa on 14-5-26.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import "NSURLRequest+RequestParams.h"
#import <objc/runtime.h>

static void *HttpRequestParams;

@implementation NSURLRequest (requestParams)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &HttpRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &HttpRequestParams);
}

@end
