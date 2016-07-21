//
//  HttpSignatureGenerator.h
//  test
//
//  Created by mutouren on 12/24/15.
//  Copyright © 2015 mutouren. All rights reserved.
//  签名生产者

#import <Foundation/Foundation.h>

@interface HttpSignatureGenerator : NSObject

+(NSString*)signHttpGETWithRequestParams:(NSDictionary*)param;
+(NSString*)signHttpPOSTWithRequestParams:(NSDictionary*)param;

@end
