//
//  HttpResponse.h
//  test
//
//  Created by mutouren on 12/24/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HttpResponseStatus)
{
    HttpResponseStatusSuccess, //作为管理层，为更底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的BaseHttpServer来决定。
    HttpResponseStatusErrorTimeout,
    HttpResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};


@interface HttpResponse : NSObject

@property (nonatomic, assign, readonly) HttpResponseStatus status;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, copy, readonly) NSDictionary *content;
@property (nonatomic, copy, readonly) NSString *encryptContent;

- (instancetype)initWithResponseRequestID:(NSNumber*)requestID request:(NSURLRequest*)request responseData:(NSData*)responseData error:(NSError*)error;


@end
