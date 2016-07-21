//
//  httpServerContext.h
//  test
//
//  Created by mutouren on 12/23/15.
//  Copyright © 2015 mutouren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface httpServerContext : NSObject


@property (nonatomic, copy) NSString *keyfrom;          //key用户名
@property (nonatomic, copy) NSString *key;              //key
@property (nonatomic, copy) NSString *type;             //请求类型
@property (nonatomic, copy) NSString *doctype;          //请求返回类型
@property (nonatomic, copy) NSString *version;          //版本

+ (instancetype)sharedInstance;

@end
