//
//  HSLogger.m
//  CWGJCarOwner
//
//  Created by mutouren on 1/14/16.
//  Copyright © 2016 mutouren. All rights reserved.
//

#import "HSLogger.h"

@implementation HSLogger


+ (void)logWithHttpServer:(BaseHttpServer*)server
{
    NSMutableString *logString = [NSMutableString
            stringWithString:@"\n\n***************************Request Start***************************\n\n"];
    
    [logString appendFormat:@"request child:\t\t%@\n", server.child];
    
    [logString appendFormat:@"service ID:\t\t%@\n", [server.child serviceID]];
    
    [logString appendFormat:@"request URL:\t\t%@\n", [server.child requestUrl]];
    
    [logString appendFormat:@"request TYPE:\t\t%@\n", [server BaseHttpServerRequestType]];
    
    [logString appendFormat:@"request PARAM:\t\t%@\n", [server requestParam]];
    
    [logString appendFormat:@"\n\n***************************Request end***************************\n\n"];
    NSLog(@"%@", logString);
}

+ (void)logWithHttpServer:(BaseHttpServer*)server HttpResponse:(HttpResponse*)response
{
    NSMutableString *logString = [NSMutableString
            stringWithString:@"\n\n***************************HttpResponse Start***************************\n\n"];
    
    [logString appendFormat:@"service ID:\t\t\t%@\n", [server.child serviceID]];
    
    [logString appendFormat:@"request status:\t\t%@\n", [server BaseHttpServerRequestStatus]];
    
    [logString appendFormat:@"request PARAM:\t\t%@\n", [server requestParam]];
    
    [logString appendFormat:@"respone content:\t\t%@\n", [response content]];
    
    [logString appendFormat:@"\n\n***************************HttpResponse end***************************\n\n"];
    NSLog(@"%@", logString);
}



@end
