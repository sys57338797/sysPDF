//
//  CarParkHttpServer.h
//  test
//
//  Created by mutouren on 12/25/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "BaseHttpServer.h"
#import "PDFWordObj.h"


@interface PDFHttpServer : BaseHttpServer

@property (nonatomic, assign ,readonly) HttpErrorCodeTable returnCode;
@property (nonatomic, strong ,readonly) NSString *returnMsg;
@property (nonatomic, strong ,readonly) id returnContent;

@property (nonatomic, strong, readonly) PDFWordObj *wordObj;

#pragma mark 清空请求成功时的返回数据
- (void)clearReturnContent;

#pragma mark 解析数据
- (void)fetchData;

- (void)requestPDFWordInfoWithWord:(NSString*)word;

@end
