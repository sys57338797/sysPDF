//
//  NSURLRequest+AIFNetworkingMethods.h
//  RTNetworking
//
//  Created by casa on 14-5-26.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>



@interface NSData(encrypt)
- (NSData *)aes256_encrypt:(NSString *)key;
- (NSData *)aes256_decrypt:(NSString *)key;

+ (NSString *)base64Encode:(NSData *)data;
+ (NSData *) base64Decode:(NSString *)string;

@end




@interface NSString(AES256)

- (NSData *)aes256_encrypt_NSDataWithKey:(NSString *)key;
- (NSString *)aes256_encrypt_NSStringWithKey:(NSString *)key;
- (NSString *)aes256_decrypt:(NSString *)key;

- (NSString *)md5HexDigest;

@end