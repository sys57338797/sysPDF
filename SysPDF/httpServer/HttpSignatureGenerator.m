//
//  HttpSignatureGenerator.m
//  test
//
//  Created by mutouren on 12/24/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import "HttpSignatureGenerator.h"
#import <CommonCrypto/CommonDigest.h>
#import "YRJSONAdapter.h"
#import "encrypt.h"




@implementation HttpSignatureGenerator


+(NSString*)signHttpGETWithRequestParams:(NSDictionary*)param
{
    return @"signature";
}

+(NSString*)signHttpPOSTWithRequestParams:(NSDictionary*)param
{
    NSString *json = [param JSONString];
//    //去掉换行符“\n”
//    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    json = [json stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [json md5HexDigest];
}

@end
