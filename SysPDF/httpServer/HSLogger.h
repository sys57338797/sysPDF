//
//  HSLogger.h
//  CWGJCarOwner
//
//  Created by mutouren on 1/14/16.
//  Copyright © 2016 mutouren. All rights reserved.
//

#import "HttpResponse.h"
#import "BaseHttpServer.h"


@interface HSLogger : NSObject

+ (void)logWithHttpServer:(BaseHttpServer*)server;

+ (void)logWithHttpServer:(BaseHttpServer*)server HttpResponse:(HttpResponse*)response;

@end
